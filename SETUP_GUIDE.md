# Setup Guide

> **⚠️ WIP (Work In Progress)**: Email authentication system is being refactored. Setup requirements may change in future versions.

This guide provides detailed instructions for setting up the Varaamo Robot Framework test environment.

## 🔐 Required Secrets

Before running tests, you need to acquire these secrets:

- **WAF Bypass Secret** (`WAF_BYPASS_SECRET`)
  - The test environment's Application Gateway and its WAF may impose traffic limits
  - During Robot Framework parallel execution, a large number of requests originate from the same source address, which can trigger WAF rate-limiting
  - The WAF bypass secret ensures that parallel test runs can proceed without interruptions
- **Robot API Token** (`ROBOT_API_TOKEN`) for test data creation
- **Django Admin Password** (`DJANGO_ADMIN_PASSWORD`) for admin operations

**📝 Where to get these secrets:**
https://helsinkisolutionoffice.atlassian.net/wiki/spaces/KAN/pages/8368848910/Robot+Framework+automaatiotestit#Passwords
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

## 🚀 Test Execution

### Running Tests via GitHub Actions

To manually run tests via GitHub Actions:

1. Go to the "Actions" tab in your GitHub repository
2. Select the "Varaamo Robot Framework Tests" workflow
3. Click "Run workflow"
4. Select which test suite you want to run from the dropdown menu
5. Choose execution mode (parallel or sequential)
6. **Optional**: Enable "Enable HAR recording" for network traffic analysis
7. Click "Run workflow"

### Workflow Features

- **Configurable test suites**: Choose from individual suites or run all
- **Execution modes**: Parallel (pabot) or sequential (robot)
- **HAR recording**: Optional network traffic recording for analysis
- **Smoke test validation**: For "All" option, runs smoke tests first
- **Docker caching**: Optimized builds with GitHub Actions cache
- **Artifact uploads**: Test reports available as downloadable artifacts
- **Comprehensive reporting**: Detailed test results and failure analysis
- **Automated HAR analysis**: Network traffic analysis when HAR recording is enabled

### HAR Analysis in GitHub Actions

When HAR recording is enabled in the workflow:

1. **Automatic Recording**: All network traffic during test execution is captured
2. **Post-Test Analysis**: HAR analyzer runs automatically after tests complete
3. **Results Integration**: Analysis summary appears in the workflow summary page

### GitHub Actions Setup

For GitHub Actions, add the following secrets to your repository:

**📝 Where to get these secrets:**
https://helsinkisolutionoffice.atlassian.net/wiki/spaces/KAN/pages/8368848910/Robot+Framework+automaatiotestit#Passwords

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add these repository secrets:
   - `WAF_BYPASS_SECRET`
   - `ROBOT_API_TOKEN`
   - `DJANGO_ADMIN_PASSWORD`

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
- Check that `ROBOT_EMAIL_ADDRESSES` is configured in Django settings so that the test environment captures emails for the address used in the robot tests

## 📚 Additional Resources

- [Robot Framework Documentation](https://docs.robotframework.org/) - For test framework details
- [TEST_ARCHITECTURE.md](TEST_ARCHITECTURE.md) - Test architecture and coverage information
- [PARALLEL_DATA_SETUP_GUIDE.md](PARALLEL_DATA_SETUP_GUIDE.md) - Comprehensive guide for parallel testing with tag-based data distribution
