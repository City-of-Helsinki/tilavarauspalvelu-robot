import os
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request
from dotenv import load_dotenv
from robot.api import logger

def load_environment_variables():
    """Load environment variables from .env file if it exists."""
    # Load from the same directory as this script to match where generate_tokens.py writes it
    env_path = os.path.join(os.path.dirname(__file__), '.env')
    loaded = load_dotenv(env_path)
    if loaded:
        logger.info(f"Successfully loaded .env file from {env_path}")
    else:
        logger.info(f"No .env file found at {env_path}; skipping loading")

def mask(token):
    """Return a masked version of the token (first 5 and last 5 characters)."""
    if token and len(token) > 10:
        return token[:5] + '...' + token[-5:]
    elif token:
        return token[:2] + '...'
    return "None"

def force_refresh_access_token():
    """Force refresh the access token using the stored refresh token."""
    # Call this at the beginning of the function to ensure logs are captured
    load_environment_variables()
    
    logger.info("="*50)  # Create a visible separator in logs
    
    token_uri = "https://oauth2.googleapis.com/token"
    access_token = os.getenv("ACCESS_TOKEN")
    refresh_token = os.getenv("REFRESH_TOKEN")
    client_id = os.getenv("CLIENT_ID")
    client_secret = os.getenv("CLIENT_SECRET")

    # Log environment info without exposing full credentials
    logger.info("Environment variables present:")
    logger.info(f"- ACCESS_TOKEN: {'Present' if access_token else 'Missing'} (length: {len(access_token) if access_token else 0})")
    logger.info(f"- REFRESH_TOKEN: {'Present' if refresh_token else 'Missing'} (length: {len(refresh_token) if refresh_token else 0})")
    logger.info(f"- CLIENT_ID: {'Present' if client_id else 'Missing'} (length: {len(client_id) if client_id else 0})")
    logger.info(f"- CLIENT_SECRET: {'Present' if client_secret else 'Missing'} (length: {len(client_secret) if client_secret else 0})")
    logger.info("="*50)
    
    # Log partial credentials for debugging
    if client_id:
        logger.info(f"CLIENT_ID starts with: {client_id[:4]}... ends with: ...{client_id[-4:]}")
    
    if not all([access_token, refresh_token, client_id, client_secret]):
        missing = []
        if not access_token: missing.append("ACCESS_TOKEN")
        if not refresh_token: missing.append("REFRESH_TOKEN")
        if not client_id: missing.append("CLIENT_ID")
        if not client_secret: missing.append("CLIENT_SECRET")
        error_msg = f"Missing one or more required environment variables for token refresh: {', '.join(missing)}"
        logger.error(error_msg)
        raise ValueError(error_msg)

    logger.info("Initializing credentials from environment variables.")
    try:
        creds = Credentials(
            token=access_token,
            refresh_token=refresh_token,
            client_id=client_id,
            client_secret=client_secret,
            token_uri=token_uri
        )
        logger.info("Credentials object created successfully")
        
        logger.info("Force refreshing access token...")
        try:
            # Create a Request object with more debugging
            request = Request()
            creds.refresh(request)
            logger.info("Access token refreshed successfully. New token (masked): " + mask(creds.token))
        except Exception as e:
            logger.error("Error refreshing token: " + str(e))
            raise
    except Exception as e:
        logger.error(f"Error creating credentials object: {str(e)}")
        raise

    return creds.token

def get_access_token():
    """Return a fresh access token by forcing a refresh."""
    token = force_refresh_access_token()
    logger.info("get_access_token() returning token (masked): " + mask(token))
    return token