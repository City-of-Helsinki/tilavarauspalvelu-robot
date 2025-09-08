# Setup Guide

> **⚠️ WIP (Work In Progress)**: Email authentication system is being refactored. Setup requirements may change in future versions.

This guide provides detailed instructions for setting up the Varaamo Robot Framework test environment.

## 🔐 Required Secrets

Before running tests, you need to acquire these secrets:

- **Google OAuth Credentials** (for email verification tests):
  - `CLIENT_ID` and `CLIENT_SECRET` from Google Cloud Console
  - `ACCESS_TOKEN` and `REFRESH_TOKEN` (generated via OAuth flow)
- **WAF Bypass Secret** (`WAF_BYPASS_SECRET`) for web application firewall

## 🔑 Environment File (.env) Location

**⚠️ Important**: The `.env` file **must** be located at `TestSuites/Resources/.env` for proper functionality.

**📍 Why this location?**
- Python scripts (`generate_tokens.py`, `token_manager.py`) write and read from this fixed location
- Ensures consistency between token generation and usage
- Prevents path-related issues when running from different directories

## 🔧 Setup Steps

### Option 1: Automatic Token Generation (Recommended)
1. **Prerequisites**: Place your `client_secret.json` file in the `TestSuites/` directory (required for OAuth flow)
2. Run `python TestSuites/Resources/generate_tokens.py` to create the `.env` file
3. The file will be automatically created at `TestSuites/Resources/.env`
4. **Manually add** other required variables to the `.env` file (see below)

### Option 2: Manual .env Setup
If you already have OAuth credentials, create `TestSuites/Resources/.env` manually with:

```bash
# Email OAuth credentials (from Google Cloud Console or token generation)
ACCESS_TOKEN=your_access_token_here
REFRESH_TOKEN=your_refresh_token_here
CLIENT_ID=your_client_id_here
CLIENT_SECRET=your_client_secret_here

# Additional required variables
WAF_BYPASS_SECRET=your_waf_bypass_secret_here
```

### 🔍 Automatic .env Discovery (Docker Scripts)

> **📝 Note for Future Development:** This automatic discovery feature is designed for future development flexibility, allowing developers to place `.env` files in various locations based on their workflow preferences.

The interactive Docker scripts (`docker-test.ps1` and `docker-test.sh`) include smart `.env` file discovery that searches multiple locations:

**Search order**:
1. `TestSuites/Resources/.env` (recommended)
2. `./.env` (project root)
3. `../.env` (parent directory)
4. `$HOME/.varaamo/.env` (user home directory)
5. Custom path via `ENV_FILE` environment variable

**🚫 Common Mistakes**: 
- ❌ Don't manually place `.env` in the root directory
- ✅ Place it at `TestSuites/Resources/.env`
- ✅ OR Use the token generation script to create it in the correct location

## 🚀 Next Steps

After setting up your `.env` file:

1. Use `--env-file TestSuites/Resources/.env` in Docker commands
2. Run the interactive Docker scripts (`docker-test.ps1` or `docker-test.sh`)
3. The scripts will automatically discover and validate your `.env` file

## 🔧 Troubleshooting

### Common Issues

**Token Generation Fails**:
- Ensure `client_secret.json` is in the `TestSuites/` directory
- Check that the file contains valid Google Cloud OAuth credentials
- Verify you have the required Gmail API scopes enabled

**Environment Variables Not Found**:
- Confirm `.env` file is at `TestSuites/Resources/.env`
- Check that all required variables are present and have values
- Use the Docker scripts' validation features to verify secrets

**Docker Scripts Can't Find .env**:
- The scripts search multiple locations automatically
- Check the console output for which `.env` file was found
- Use `ENV_FILE` environment variable to specify a custom path

## 📚 Additional Resources

- [Google Cloud Console](https://console.cloud.google.com/) - For OAuth credentials
- [Gmail API Documentation](https://developers.google.com/gmail/api) - For API setup
- [Robot Framework Documentation](https://docs.robotframework.org/) - For test framework details
