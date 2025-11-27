"""
Automatically loads environment variables from .env file when imported.
This makes secrets available when running tests locally without docker.
"""

import os
import sys
from pathlib import Path
from dotenv import load_dotenv


# Always print to stderr so it shows up in console/logs
def _log(message, level="INFO"):
    """Log to stderr so it's visible in Robot Framework output."""
    prefix = "⚠️  " if level == "WARN" else "✓ "
    print(f"{prefix}{message}", file=sys.stderr, flush=True)


# Find and load .env file
env_path = Path(__file__).parent / ".env"

if env_path.exists():
    # Load with override=False to not overwrite existing env vars (Docker sets them)
    load_dotenv(env_path, override=False)
    _log("Environment secrets loaded from .env file")
else:
    _log(f"No .env file found at: {env_path}", level="WARN")

# Export variables so Robot Framework can access them
# These become Robot Framework variables when this file is imported
WAF_BYPASS_SECRET = os.getenv("WAF_BYPASS_SECRET", "")
ROBOT_API_TOKEN = os.getenv("ROBOT_API_TOKEN", "")
DJANGO_ADMIN_PASSWORD = os.getenv("DJANGO_ADMIN_PASSWORD", "")
ROBOT_API_ENDPOINT = os.getenv("ROBOT_API_ENDPOINT", "/v1/create_robot_test_data/")

# Validate which secrets are present (without logging values)
_required = ["WAF_BYPASS_SECRET", "ROBOT_API_TOKEN", "DJANGO_ADMIN_PASSWORD"]

_missing_required = []

for _var in _required:
    if not os.getenv(_var):
        _missing_required.append(_var)

# Warn about missing required secrets
if _missing_required:
    _log(f"WARNING: Missing required secrets: {', '.join(_missing_required)}", level="WARN")

# Success message only if all required secrets are present
if not _missing_required:
    _log("All required secrets present")
