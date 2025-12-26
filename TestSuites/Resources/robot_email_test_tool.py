"""
Robot Framework Email Testing Tool
Works with the backend email cache API
"""

import requests
from robot.api import logger
from typing import List, Dict, Any, Optional


class RobotEmailTester:
    """
    Email tester that retrieves emails from the backend cache API.
    """

    def __init__(self, api_endpoint: str, robot_email: str):
        """
        Initialize the email tester.

        Args:
            api_endpoint: Full URL to the email cache API endpoint
            robot_email: The robot test email address to filter emails
        """
        self.api_endpoint = api_endpoint.rstrip("/")
        self.robot_email = robot_email
        logger.info(f"Initialized RobotEmailTester with API endpoint: {self.api_endpoint}")
        logger.info(f"Robot email: {self.robot_email}")

    def get_emails(self, recipient: Optional[str] = None, subject: Optional[str] = None) -> List[Dict[str, Any]]:
        """
        Retrieve emails from the backend cache.

        Args:
            recipient: Optional recipient filter
            subject: Optional subject filter (note: reservation numbers are in body, not subject)

        Returns:
            List of email dictionaries sorted by timestamp (newest first), containing:
            timestamp, recipients, subject, text_content, and attachments
        """
        params = {}
        if recipient:
            params["recipient"] = recipient
        if subject:
            params["subject"] = subject

        try:
            logger.info(f"Fetching emails from: {self.api_endpoint}")
            logger.info(f"Params: {params}")

            response = requests.get(self.api_endpoint, params=params, timeout=10)
            response.raise_for_status()

            emails = response.json()
            logger.info(f"Retrieved {len(emails)} emails from cache (sorted newest-first)")

            return emails
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to retrieve emails from cache: {str(e)}")
            return []

    def verify_reservation_email(
        self, reservation_number: str, expected_terms: List[str], require_attachment: bool = False
    ) -> bool:
        """
        Verify that an email exists with the reservation number and contains all expected terms.

        Args:
            reservation_number: The reservation number to search for (found in email body)
            expected_terms: List of terms that should be present in the email
            require_attachment: Whether an attachment is required

        Returns:
            True if a matching email is found with all terms, False otherwise
        """
        logger.info(f"Verifying email for reservation: {reservation_number}")
        logger.info(f"Expected terms: {expected_terms}")
        logger.info(f"Require attachment: {require_attachment}")

        # Get all emails for the robot email recipient
        # Note: Reservation number is in the body, not subject, so we filter client-side
        emails = self.get_emails(recipient=self.robot_email)

        if not emails:
            logger.error(f"No emails found for recipient: {self.robot_email}")
            return False

        logger.info(f"Retrieved {len(emails)} total emails from cache (sorted newest-first)")

        # Filter emails that contain the reservation number in subject or content
        matching_emails = []
        for email_data in emails:
            subject = email_data.get("subject", "") or ""
            text_content = email_data.get("text_content", "") or ""

            # Check if reservation number is in subject or content
            if reservation_number in subject or reservation_number in text_content:
                matching_emails.append(email_data)

        if not matching_emails:
            logger.error(f"No emails found containing reservation number: {reservation_number}")
            logger.error(f"   Total emails checked: {len(emails)}")
            return False

        logger.info(f"Found {len(matching_emails)} emails matching reservation number {reservation_number}")

        # Log all matching email subjects for debugging (emails are already sorted newest-first)
        if len(matching_emails) > 0:
            logger.info("Matching email subjects (newest first):")
            for idx, email_data in enumerate(matching_emails):
                timestamp = email_data.get("timestamp", "N/A")
                subject = email_data.get("subject", "N/A")
                logger.info(f"   [{idx}] {timestamp}: {subject}")

        # Warn if more than expected emails found (should be 1-2: confirmation + cancellation)
        if len(matching_emails) > 2:
            logger.warn(f"⚠️  Found {len(matching_emails)} emails for reservation {reservation_number} (expected 1-2)")
            logger.warn("   This might indicate duplicate emails or test data issues")

        # Check each matching email for all required terms (starting with newest)
        for idx, email_data in enumerate(matching_emails):
            text_content = email_data.get("text_content", "") or ""  # Null safety
            attachments = email_data.get("attachments", []) or []
            timestamp = email_data.get("timestamp", "")
            subject = email_data.get("subject", "")

            logger.info(f"Checking email [{idx}] from {timestamp}")

            # Verify reservation number is actually in the email (double-check)
            if reservation_number not in subject and reservation_number not in text_content:
                logger.warn(f"Email [{idx}] doesn't contain reservation number - skipping")
                continue

            # Check all expected terms
            missing_terms = []
            for term in expected_terms:
                if term and term.lower() not in text_content.lower():
                    missing_terms.append(term)

            # Check attachment requirement
            has_attachment = len(attachments) > 0
            if require_attachment and not has_attachment:
                logger.warn(f"Email [{idx}] is missing required attachment (found {len(attachments)} attachments)")
                continue

            if not missing_terms:
                logger.info(f"✅ Email verification passed! (Email [{idx}] - most recent match)")
                logger.info(f"   - Timestamp: {timestamp}")
                logger.info(f"   - Subject: {subject}")
                logger.info(f"   - All {len(expected_terms)} terms found")
                logger.info(f"   - Attachments: {len(attachments)}")
                if attachments:
                    logger.info(f"   - Attachment files: {', '.join(attachments)}")
                return True
            else:
                logger.warn(f"Email [{idx}] is missing terms: {', '.join(missing_terms)}")

        # If we get here, no email matched all criteria
        logger.error("❌ No email found matching all criteria")
        logger.error(f"   - Reservation number: {reservation_number}")
        logger.error(f"   - Required terms: {expected_terms}")
        logger.error(f"   - Require attachment: {require_attachment}")
        logger.error(f"   - Total emails checked: {len(emails)}")
        logger.error(f"   - Matching emails found: {len(matching_emails)}")

        # Show sample content from most recent matching email for debugging
        if matching_emails:
            first_email = matching_emails[0]
            sample_text = (first_email.get("text_content", "") or "")[:300]
            logger.error(f"   - Sample from most recent email: {sample_text}...")

        return False


# Robot Framework keyword functions
def verify_reservation_email(
    reservation_number: str, expected_terms: List[str], require_attachment: bool = False
) -> bool:
    """
    Verify reservation email. Auto-initializes email tester if needed.

    Args:
        reservation_number: Reservation number to search for
        expected_terms: List of terms that should be in the email
        require_attachment: Whether an attachment is required

    Returns:
        True if verification passed, False otherwise
    """
    from robot.libraries.BuiltIn import BuiltIn

    builtin = BuiltIn()

    try:
        # Try to get existing tester, or create one if it doesn't exist
        email_tester = builtin.get_variable_value("${EMAIL_TESTER}")
        if email_tester is None:
            # Auto-initialize using fixed variables
            api_endpoint = builtin.get_variable_value("${DJANGO_ROBO_MAIL}")
            robot_email = builtin.get_variable_value("${ROBOT_EMAIL}")

            if not api_endpoint or not robot_email:
                logger.error("DJANGO_ROBO_MAIL and ROBOT_EMAIL must be set as variables.")
                return False

            email_tester = RobotEmailTester(api_endpoint, robot_email)
            builtin.set_suite_variable("${EMAIL_TESTER}", email_tester)
            logger.info("Auto-initialized email tester")

        return email_tester.verify_reservation_email(reservation_number, expected_terms, require_attachment)
    except Exception as e:
        logger.error(f"Error in verify_reservation_email: {str(e)}")
        return False
