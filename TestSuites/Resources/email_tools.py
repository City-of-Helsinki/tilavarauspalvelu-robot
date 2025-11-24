import os
import imaplib
import email
import json
import re
from bs4 import BeautifulSoup
from token_manager import get_access_token
from robot.api import logger  # For logging

###
#   EMAIL PART
###


def clean_and_save_emails(email_texts, output_file="emails_cleaned.json"):
    """
    Clean, format, and save email texts to a structured JSON file, including attachment status of
    general_terms_attachment.

    Args:
        email_texts (list): A list of dictionaries where keys are email UIDs and values include email content and attachment status.
        output_file (str): Path to the output file to save the cleaned emails.
    """
    cleaned_emails = []

    for email_entry in email_texts:
        for uid, details in email_entry.items():
            # Ensure `details` includes 'content'
            content = details.get("content", "")
            if not isinstance(content, str):
                logger.error(f"Email content for UID {uid} is not a string: {content}")
                continue

            # Clean and format content
            cleaned_content = content.replace("\n", " ")  # Replace \n with space
            cleaned_content = re.sub(r"\s+", " ", cleaned_content.strip())  # Normalize spaces

            # Include attachment status if available
            cleaned_emails.append(
                {
                    "uid": uid,
                    "content": cleaned_content,
                    "general_terms_attachment": details.get("general_terms_attachment", False),  # Updated key
                }
            )

    # Save the cleaned and formatted emails to a JSON file
    try:
        with open(output_file, "w", encoding="utf-8") as file:
            json.dump(cleaned_emails, file, ensure_ascii=False, indent=4)
        logger.info(f"Cleaned emails saved to {output_file}.")
    except Exception as e:
        logger.error(f"Failed to save cleaned emails: {str(e)}")


def search_reservations(email_address, reservation_num, attachment_filename, downloads_dir):
    """
    Search for emails containing a specific reservation number and extract their text content.
    Check for a specific attachment in the emails.

    Args:
        email_address (str): The Gmail address to access.
        reservation_num (str): The reservation number to search for in the emails.
        attachment_filename (str): The filename of the specific attachment to check.
        downloads_dir (str): Directory where the cleaned emails file should be saved.


    Returns:
        list: A list of extracted email texts with attachment information.
    """
    imap_ssl_host = "imap.gmail.com"
    imap_ssl_port = 993

    access_token = get_access_token()
    if not access_token:
        logger.info("Access token is not available. Aborting operation.")
        raise Exception("Access token is not available.")

    mail = None
    email_texts = []

    try:
        logger.info("Establishing connection to Gmail IMAP server...")
        mail = imaplib.IMAP4_SSL(imap_ssl_host, imap_ssl_port)

        logger.info("Authenticating using XOAUTH2...")
        auth_string = f"user={email_address}\1auth=Bearer {access_token}\1\1"
        mail.authenticate("XOAUTH2", lambda x: auth_string)

        logger.info("Selecting the inbox...")
        status, data = mail.select("inbox")
        if status != "OK":
            logger.error("Failed to select the inbox. Check access permissions or inbox availability.")
            raise Exception("Failed to select inbox.")

        logger.info(f"Searching for emails containing reservation number: {reservation_num}")
        search_criteria = f'(BODY "{reservation_num}")'
        status, data = mail.search(None, search_criteria)
        if status != "OK" or not data or not data[0]:
            logger.info(f"No emails found with reservation number: {reservation_num}")
            return []

        for num in data[0].split():
            logger.info(f"Fetching email with UID: {num.decode()}")
            status, email_data = mail.fetch(num, "(RFC822)")
            if status != "OK":
                logger.error(f"Failed to fetch email with UID: {num.decode()}")
                continue

            for response_part in email_data:
                if isinstance(response_part, tuple):  # Ensure valid email response
                    msg = email.message_from_bytes(response_part[1])
                    extracted_content = extract_email_content(
                        msg, attachment_filename
                    )  # This checks if the general terms attachment is present
                    unique_id = f"Email-{num.decode()}"
                    email_texts.append({unique_id: extracted_content})  # Store extracted content

        logger.info(f"Total matched emails: {len(email_texts)}")

        # Default the output file to the downloads folder if the environment variable isn't set.
        default_path = os.path.join(downloads_dir, "cleaned_emails.json")

        output_file = os.environ.get("CLEANED_EMAILS_PATH", default_path)

        # Log the absolute path where the file will be saved.
        clean_and_save_emails(email_texts, output_file=output_file)

    except imaplib.IMAP4.error as e:
        logger.error(f"IMAP4 error during operation: {str(e)}")
        raise Exception(f"Failed to authenticate with Gmail IMAP: {str(e)}")
    except Exception as e:
        logger.error(f"An unexpected error occurred: {str(e)}")
        raise
    finally:
        if mail:
            logger.info("Logging out of the Gmail IMAP server...")
            try:
                mail.logout()
            except Exception as e:
                logger.error(f"Failed to log out: {str(e)}")

    return email_texts


def extract_email_content(msg, attachment_filename):
    """
    Extract the plain text content from an email message and check for a specific attachment.

    Args:
        msg (email.message.Message): The email message object.
        attachment_filename (str): The filename of the specific attachment to check.

    Returns:
        dict: A dictionary containing the email content and whether the specific attachment was found.
    """
    plain_text = None
    html_text = None
    general_terms_attachment = False

    if msg.is_multipart():
        for part in msg.walk():
            content_type = part.get_content_type()
            content_disposition = str(part.get("Content-Disposition"))

            if content_type == "text/plain" and "attachment" not in content_disposition:
                plain_text = part.get_payload(decode=True).decode()
            elif content_type == "text/html" and "attachment" not in content_disposition:
                html_text = part.get_payload(decode=True).decode()
            elif "attachment" in content_disposition:
                filename = part.get_filename()
                payload = part.get_payload(decode=True)
                size = len(payload) if payload else 0

                logger.info(f"Attachment '{filename}' found with size {size} bytes.")

                if filename == attachment_filename and size > 0:
                    logger.info(f"Specific attachment '{attachment_filename}' detected and meets size requirement.")
                    general_terms_attachment = True

    else:
        content_type = msg.get_content_type()
        if content_type == "text/plain":
            plain_text = msg.get_payload(decode=True).decode()
        elif content_type == "text/html":
            html_text = msg.get_payload(decode=True).decode()

    email_content = plain_text.strip() if plain_text else clean_html(html_text) if html_text else "No content found."
    return {"content": email_content, "general_terms_attachment": general_terms_attachment}


def clean_html(html):
    """
    Clean and extract readable text from HTML content.
    """
    soup = BeautifulSoup(html, "html.parser")

    # Remove scripts and styles
    for script_or_style in soup(["script", "style"]):
        script_or_style.extract()

    # Get text
    text = soup.get_text()

    # Break lines and remove redundant spaces
    lines = (line.strip() for line in text.splitlines())
    chunks = (phrase.strip() for line in lines for phrase in line.split("  "))
    text = "\n".join(chunk for chunk in chunks if chunk)
    return text


def check_email_content(file_path, *required_terms):
    """
    Check if all required terms are present in at least one entry's content,
    and verify the attachment status if provided.

    Args:
        file_path (str): Path to the JSON file to check.
        required_terms (list): Terms to check for in the content of each entry.

    Returns:
        bool: True if all terms and optional attachment status are found in at least one entry, False otherwise.
    """
    # Resolve and validate file path
    resolved_file_path = os.path.abspath(file_path)
    logger.info(f"--- Checking email content in: {resolved_file_path} ---")

    if not os.path.exists(resolved_file_path):
        logger.error(f"File not found: {resolved_file_path}")
        return False

    # Load the JSON data
    try:
        with open(resolved_file_path, "r", encoding="utf-8") as file:
            email_data = json.load(file)
        logger.info(f"Successfully loaded email content from: {resolved_file_path}")
    except Exception as e:
        logger.error(f"Failed to load JSON file: {str(e)}")
        return False

    if not isinstance(email_data, list):
        logger.error("Invalid JSON structure: Expected a list of email entries.")
        return False

    # Convert required terms to mutable list
    required_terms = list(required_terms)
    expected_attachment_status = None

    if required_terms and isinstance(required_terms[-1], bool):
        expected_attachment_status = required_terms.pop()  # Get and remove boolean status term

    logger.info(f"Searching for terms: {', '.join(map(str, required_terms))}")
    if expected_attachment_status is not None:
        logger.info(f"Expected attachment status: {expected_attachment_status}")

    all_terms_found = False
    found_uid = None
    missing_terms_summary = {}

    for entry in email_data:
        uid = entry.get("uid", "Unknown UID")
        content = entry.get("content", "")
        attachment_status = entry.get("general_terms_attachment", False)

        # Check required terms
        missing_terms = [term for term in required_terms if term.lower().strip() not in content.lower().strip()]

        # Check attachment status
        if not missing_terms and (
            expected_attachment_status is None or attachment_status == expected_attachment_status
        ):
            found_uid = uid
            logger.info(f"✅ Email UID {found_uid} passed with all terms and attachment status: {attachment_status}.")
            all_terms_found = True
            break  # Stop checking once we find a match
        else:
            missing_terms_summary[uid] = missing_terms
            if expected_attachment_status is not None and attachment_status != expected_attachment_status:
                missing_terms_summary[uid].append(
                    f"Expected attachment status: {expected_attachment_status}, found: {attachment_status}"
                )

    if not all_terms_found:
        logger.error("❌ No email contains all required terms with the expected attachment status.")
        for uid, missing in missing_terms_summary.items():
            logger.error(f"UID {uid} is missing terms: {', '.join(missing)}")
        return False

    return True
