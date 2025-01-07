import locale
import re
from itertools import zip_longest
from robot.api import logger  # Import Robot Framework's logger


def get_finnish_day(date_time):
    
    """
    Get the abbreviated Finnish day name from a datetime object.
    """
    # Set the locale to Finnish
    try:
        locale.setlocale(locale.LC_TIME, 'fi_FI.UTF-8')
    except locale.Error as e:
        logger.warn(f"Locale setting failed: {e}")
        return None
    
    # Return the abbreviated day of the week in Finnish
    return date_time.strftime('%a').capitalize()  # Capitalizes the first letter, Returns day of the week in Finnish (e.g., ma, ti)

def log_differences(elementsText, expectedText, verbose=True, name1="elementsText", name2="expectedText"):
    """
    Compare two texts character by character and log differences, including ASCII and HEX values.
    
    Args:
        elementsText (str): First text to compare.
        expectedText (str): Second text to compare.
        verbose (bool): If True, logs detailed differences; otherwise, logs only a summary.
        name1 (str): Label for the first text (default is 'elementsText').
        name2 (str): Label for the second text (default is 'expectedText').
        
    Returns:
        list of dict: A list of dictionaries, each containing details of the differences.
    """
    # Check if inputs are strings
    if not isinstance(elementsText, str) or not isinstance(expectedText, str):
        logger.warn("Both inputs must be strings.")
        return []
    
    # Check if both strings are empty
    if not elementsText and not expectedText:
        logger.warn("Both strings are empty. Nothing to compare.")
        return []
    
    differences = []

    # Log the start of the comparison
    logger.info(f"Starting comparison between {name1} and {name2}.")
    
    # Iterate over both strings character by character
    for i, (char1, char2) in enumerate(zip_longest(elementsText, expectedText, fillvalue='')):
        if char1 != char2:
            try:
                # Get ASCII and HEX values for the characters
                ascii1 = ord(char1) if char1 else 'N/A'
                ascii2 = ord(char2) if char2 else 'N/A'
                hex1 = hex(ascii1) if ascii1 != 'N/A' else 'N/A'
                hex2 = hex(ascii2) if ascii2 != 'N/A' else 'N/A'
            except Exception:
                ascii1, hex1 = 'N/A', 'N/A'
                ascii2, hex2 = 'N/A', 'N/A'
                
            # Store the difference information in a dictionary
            diff_info = {
                "position": i,
                name1: {"char": char1, "ascii": ascii1, "hex": hex1},
                name2: {"char": char2, "ascii": ascii2, "hex": hex2},
            }
            differences.append(diff_info)
            if verbose:
                # Log detailed difference information if verbose is True
                logger.info(f"Difference found at position {i}: {diff_info}")

    # Log the summary of differences found
    if differences:
        logger.info(f"{len(differences)} differences found.")
    else:
        logger.info("No differences found.")
    
    return differences



def validate_timeformat(original_time):
    """
    Validates if the given original_time is in the format like 'Pe 13.9.2024 klo 11:45–12:45'.
    Returns a boolean indicating whether the format is valid.
    This uses en dash (–) between the start and end times.
    """
    # Regular expression pattern to match the time format, including "klo"
    pattern = r'^[A-Za-z]{2}\s\d{1,2}\.\d{1,2}\.\d{4}\sklo\s\d{2}[:.]\d{2}–\d{2}[:.]\d{2}$'
        
    # Validate the format
    time_format_is_valid = re.match(pattern, original_time) is not None
        
    # Output result for debugging/logging using Robot Framework's logger
    if time_format_is_valid:
        logger.info(f"The time format is valid: {original_time}")
    else:
        logger.info(f"The time format is invalid: {original_time}")
        
    # Return validation result
    return time_format_is_valid


###
###
###

def extract_time(string, delimiters):
    """
    Extracts the time substring from the input string based on the specified delimiters.
    
    :param string: The input string.
    :param delimiters: A list of delimiters to search for.
    :return: The extracted time substring.
    """
    index = -1
    delimiter_found = ''
    for delimiter in delimiters:
        index = string.find(delimiter)
        if index != -1:
            delimiter_found = delimiter
            break
    if index == -1:
        raise ValueError(f"None of the delimiters {delimiters} found in '{string}'")
    
    offset = 3 if delimiter_found == 'klo' else 1
    time = string[index + offset:index + offset + 5]
    
    # Additional validation to ensure time is in HH:MM or HH.MM format
    if not re.match(r'^\d{1,2}[:.]\d{2}$', time):
        raise ValueError(f"Invalid time format found: '{time}'")
    
    logger.info(f"Extracted time: {time}")
    return time


def format_time_to_ics(time_string):
    """
    Formats a time string into the HHMMSS format required for ICS files.

    :param time_string: The time string to format (e.g., '10.30').
    :return: The formatted time string in HHMMSS format.
    """
    numeric_time_string = ''.join(filter(str.isdigit, time_string))
    formatted_time = pad_time_string(numeric_time_string)
    logger.info(f"Formatted time: {formatted_time}")
    return formatted_time

def pad_time_string(time_string):
    """
    Pads the time string to ensure it is in HHMMSS format.

    :param time_string: The numeric time string (e.g., '1030' or '930').
    :return: The padded time string in HHMMSS format.
    """
    if len(time_string) == 3:
        time_string = '0' + time_string
    hours = time_string[:2]
    minutes = time_string[2:4]
    padded_time = f'{hours}{minutes}00'
    logger.info(f"Padded time string: {padded_time}")
    return padded_time

def format_date_to_ics(date_string):
    """
    Formats a date string into the YYYYMMDD format required for ICS files.

    :param date_string: The date string to format (e.g., '1.10.2024').
    :return: The formatted date string in YYYYMMDD format.
    """

    if not re.match(r'^\d{1,2}\.\d{1,2}\.\d{4}$', date_string):
        raise ValueError(f"Invalid date format: {date_string}")

    date_parts = date_string.split('.')
    day = pad_with_leading_zero(date_parts[0])
    month = pad_with_leading_zero(date_parts[1])
    year = date_parts[2]
    formatted_date = f'{year}{month}{day}'
    logger.info(f"Formatted date: {formatted_date}")
    return formatted_date

def pad_with_leading_zero(value):
    """
    Pads a numeric string with a leading zero if necessary.

    :param value: The numeric string to pad (e.g., '1', '10').
    :return: The padded string with at least two digits.
    """
    padded_value = value.zfill(2)
    logger.info(f"Padded value: {padded_value}")
    return padded_value

def convert_to_ics_datetime(date, time):
    """
    Combines date and time strings into the ICS datetime format without time zone conversion.

    :param date: The date string in YYYYMMDD format.
    :param time: The time string in HHMMSS format.
    :return: The ICS datetime string in the format YYYYMMDDTHHMMSS.
    """
    datetime_string = f'{date}T{time}'
    logger.info(f"Converted to ICS datetime: {datetime_string}")
    return datetime_string

def convert_booking_time_to_ics(time_string):
    """
    Converts a booking time string to ICS format with time zone information.

    param time_string: String containing date and time information.
        Example: "Ti 1.10.2024 klo 10.30 – 11.30"
    return: A tuple containing ICS formatted DTSTART and DTEND strings with TZID.
        Example: "DTSTART;TZID=Europe/Helsinki:20241001T103000", "DTEND;TZID=Europe/Helsinki:20241001T113000"

    """
    logger.info(f"Processing time string: {time_string}")

    # Remove all spaces from the time string
    trimmed_time_string = time_string.replace(' ', '')

    # Extract date using regex to match a day, month, and year in Finnish date format
    date_match = re.search(r'\b(\d{1,2}\.\d{1,2}\.\d{4})\b', time_string)
    if not date_match:  raise ValueError("Date format not found in input string.")

    sanitized_date = date_match.group(1)
    logger.info(f"Sanitized date: {sanitized_date}")

    # Extract times based on delimiters
    start_time = extract_time(trimmed_time_string, ['klo'])
    end_time = extract_time(trimmed_time_string, ['–', '-'])  # Try both en dash and hyphen
    logger.info(f"Start time: {start_time}, End time: {end_time}")

    # Format date and times
    formatted_date = format_date_to_ics(sanitized_date)
    formatted_start_time = format_time_to_ics(start_time)
    formatted_end_time = format_time_to_ics(end_time)
    logger.info(f"Formatted date: {formatted_date}")
    logger.info(f"Formatted start time: {formatted_start_time}, Formatted end time: {formatted_end_time}")

    # Combine date and time into ICS datetime strings
    ics_start_datetime = convert_to_ics_datetime(formatted_date, formatted_start_time)
    ics_end_datetime = convert_to_ics_datetime(formatted_date, formatted_end_time)
    logger.info(f"ICS start datetime: {ics_start_datetime}, ICS end datetime: {ics_end_datetime}")

    # Specify the time zone identifier
    timezone_id = 'Europe/Helsinki'

    # Build ICS start and end strings with TZID parameter
    ics_start = f'DTSTART;TZID={timezone_id}:{ics_start_datetime}'
    ics_end = f'DTEND;TZID={timezone_id}:{ics_end_datetime}'

    return ics_start, ics_end
