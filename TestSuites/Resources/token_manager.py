import os
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request
from dotenv import load_dotenv
from robot.api import logger

# Load environment variables for local development.
load_dotenv()

def mask(token):
    """Return a masked version of the token (first 5 and last 5 characters)."""
    if token and len(token) > 10:
        return token[:5] + '...' + token[-5:]
    return token

def force_refresh_access_token():
    """Force refresh the access token using the stored refresh token."""
    token_uri = "https://oauth2.googleapis.com/token"
    access_token = os.getenv("ACCESS_TOKEN")
    refresh_token = os.getenv("REFRESH_TOKEN")
    client_id = os.getenv("CLIENT_ID")
    client_secret = os.getenv("CLIENT_SECRET")

    if not all([access_token, refresh_token, client_id, client_secret]):
        raise ValueError("Missing one or more required environment variables for token refresh.")

    logger.info("Initializing credentials from environment variables.")
    creds = Credentials(
        token=access_token,
        refresh_token=refresh_token,
        client_id=client_id,
        client_secret=client_secret,
        token_uri=token_uri
    )
    
    logger.info("Force refreshing access token...")
    try:
        creds.refresh(Request())
        logger.info("Access token refreshed successfully. New token (masked): " + mask(creds.token))
    except Exception as e:
        logger.error("Error refreshing token: " + str(e))
        raise

    return creds.token

def get_access_token():
    """Return a fresh access token by forcing a refresh."""
    token = force_refresh_access_token()
    logger.info("get_access_token() returning token (masked): " + mask(token))
    return token
