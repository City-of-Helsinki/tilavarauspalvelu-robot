import os
from google_auth_oauthlib.flow import InstalledAppFlow
from robot.api import logger  # Import Robot Framework logger


SCOPES = [
    "https://mail.google.com/",
    "https://www.googleapis.com/auth/gmail.readonly",
    "https://www.googleapis.com/auth/gmail.modify",
    "https://www.googleapis.com/auth/gmail.compose",
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/userinfo.profile",
    "openid",
]


def generate_tokens():
    # Determine the directory where the current file is located.
    base_dir = os.path.dirname(os.path.abspath(__file__))

    # Construct the path to the client_secret.json file, assumed to be in the parent directory.
    client_secrets_file = os.path.join(base_dir, "..", "client_secret.json")

    if not os.path.exists(client_secrets_file):
        logger.error(f"client_secret.json not found at '{client_secrets_file}'")
        return

    logger.info("Starting OAuth 2.0 flow. Please authorize in the browser...")
    flow = InstalledAppFlow.from_client_secrets_file(client_secrets_file, SCOPES)
    creds = flow.run_local_server(port=0)

    # Automatically update .env file with tokens
    env_path = os.path.join(base_dir, ".env")
    try:
        with open(env_path, "w") as f:
            f.write(f"ACCESS_TOKEN={creds.token}\n")
            f.write(f"REFRESH_TOKEN={creds.refresh_token}\n")
            f.write(f"CLIENT_ID={creds.client_id}\n")
            f.write(f"CLIENT_SECRET={creds.client_secret}\n")
        logger.info(f".env file updated at {env_path}")
    except Exception as e:
        logger.error(f"Failed to update .env file: {e}")


if __name__ == "__main__":
    generate_tokens()
