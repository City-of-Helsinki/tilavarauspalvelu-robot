# Setup Guide

> **⚠️ WIP (Work In Progress)**: Email authentication system is being refactored. Setup requirements may change in future versions.

This guide provides detailed instructions for setting up the Varaamo Robot Framework test environment.

## 🔐 Required Secrets

Before running tests, you need to acquire these secrets:

- **WAF Bypass Secret** (`WAF_BYPASS_SECRET`) for web application firewall
- **Robot API Token** (`ROBOT_API_TOKEN`) for test data creation
- **Django Admin Password** (`DJANGO_ADMIN_PASSWORD`) for admin operations

**📝 Where to get these secrets:**
- TODO

## 🔑 Environment File (.env) Location

**⚠️ Important**: The `.env` file **must** be located at `TestSuites/Resources/.env` for proper functionality.

**📍 Why this location?**
- The `env_loader.py` script automatically loads environment variables from this location
- Ensures consistency across all test runs
- Prevents path-related issues when running from different directories

## 🔧 Setup Steps

### Manual .env Setup
Create `TestSuites/Resources/.env` manually with:

```bash
# Required secrets
WAF_BYPASS_SECRET=your_waf_bypass_secret_here
ROBOT_API_TOKEN=your_robot_api_token_here
DJANGO_ADMIN_PASSWORD=your_django_admin_password_here
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

## 🚀 Next Steps

After setting up your `.env` file:

1. Use `--env-file TestSuites/Resources/.env` in Docker commands
2. Run the interactive Docker scripts (`docker-test.ps1` or `docker-test.sh`)
3. The scripts will automatically discover and validate your `.env` file

## 🔧 Troubleshooting

### Common Issues

**Environment Variables Not Found**:
- Confirm `.env` file is at `TestSuites/Resources/.env`
- Check that all required variables are present and have values
- Use the Docker scripts' validation features to verify secrets

**Docker Scripts Can't Find .env**:
- The scripts search multiple locations automatically
- Check the console output for which `.env` file was found
- Use `ENV_FILE` environment variable to specify a custom path

**Email Tests Failing**:
- Verify the backend email cache endpoint is available at `${TEST_BASE_URL}/v1/robot_email_cache/`
- Check that `ROBOT_EMAIL_ADDRESSES` is configured in Django settings

## 📚 Additional Resources

- [Robot Framework Documentation](https://docs.robotframework.org/) - For test framework details
- [EMAIL_QUICK_START.md](EMAIL_QUICK_START.md) - Quick start guide for email testing
- [EMAIL_MIGRATION_GUIDE.md](EMAIL_MIGRATION_GUIDE.md) - Migration guide from Gmail to cache API
