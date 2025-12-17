# Setup Guide

> **⚠️ WIP (Work In Progress)**: Email authentication system is being refactored. Setup requirements may change in future versions.

This guide provides detailed instructions for setting up the Varaamo Robot Framework test environment.

## 🔐 Required Secrets

Before running tests, you need to acquire these secrets:

- **WAF Bypass Secret** (`WAF_BYPASS_SECRET`)
  - The test environment's Application Gateway and its WAF may impose traffic limits
  - During Robot Framework parallel execution, a large number of requests originate from the same source address, which can trigger WAF rate-limiting
  - **Without this secret, you will encounter many 403 (Forbidden) errors** during test execution
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

### Automatic .env Loading

**For Local Execution:**
- `env_loader.py` automatically loads `.env` from `TestSuites/Resources/.env` when tests run
- No manual configuration needed - just create the file and run tests

**For Docker Execution:**
- Docker scripts automatically discover and load the `.env` file
- **PowerShell script** searches 5 locations (including parent dir, home dir, custom path)
- **Bash script** searches 2 locations (TestSuites/Resources/.env, then project root)
- See Docker Execution section below for details

**🚫 Common Mistakes**:
- ❌ Don't manually place `.env` in the root directory
- ✅ Place it at `TestSuites/Resources/.env` (recommended, works everywhere)

## 🐳 Docker Execution

### .env File Discovery

The Docker scripts have different search behaviors:

**PowerShell (`docker-test.ps1`)** - Smart multi-location search:
1. `TestSuites/Resources/.env` (recommended)
2. `./.env` (project root)
3. `../.env` (parent directory)
4. `$env:USERPROFILE/.varaamo/.env` (user home directory)
5. Custom path via `$env:ENV_FILE` environment variable

**Bash (`docker-test.sh`)** - Simple 2-location search:
1. `TestSuites/Resources/.env` (can be configured in `docker-config.json`)
2. `./.env` (project root) - fallback only

**Loaded variables** (both scripts):
- `WAF_BYPASS_SECRET`
- `ROBOT_API_TOKEN`
- `ROBOT_API_ENDPOINT`
- `DJANGO_ADMIN_PASSWORD`

## 🚀 Running Tests in Docker

After setting up your `.env` file:

1. Use `--env-file TestSuites/Resources/.env` in Docker commands
2. Run the interactive Docker scripts (`docker-test.ps1` or `docker-test.sh`)
3. The scripts will automatically discover and validate your `.env` file

The interactive test runner will allow you to select and execute tests.

## 🖥️ Local Execution With Robocorp Extension

**Prerequisites**: Install Robot Framework and Browser library. See [EDITOR_SETUP_GUIDE.md](EDITOR_SETUP_GUIDE.md) for editor setup with Robocorp extension.

### Create .env File

Create `TestSuites/Resources/.env` manually with the required secrets (see Required Secrets section above).

## 🚀 Running Tests Locally

After creating your `.env` file, you can run tests using your IDE's Robot Framework extension or command line.

## ☁️ GitHub Actions Execution

### Setup

For GitHub Actions, add the following secrets to your repository:

**📝 Where to get these secrets:**
https://helsinkisolutionoffice.atlassian.net/wiki/spaces/KAN/pages/8368848910/Robot+Framework+automaatiotestit#Passwords

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add these repository secrets:
   - `WAF_BYPASS_SECRET`
   - `ROBOT_API_TOKEN`
   - `DJANGO_ADMIN_PASSWORD`

### Running Tests in GitHub Actions

### Manual Workflow Trigger

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

## 🔧 Troubleshooting

### Common Issues (All Execution Modes)

#### First Steps When Tests Fail

If tests fail, follow this quick verification flow:

1. **Re-run the failed test** - Run the same test again to verify the failure is reproducible
2. **Check consistency** - Note if the test fails at the same phase with the same error message
3. **Determine failure type**:
   - **Consistent failure** (same error, same phase): Could be one of the following → Continue with troubleshooting below
     - **Application bug** - The actual application has a real bug that the test correctly found
     - **Configuration issue** - Wrong environment variables, missing secrets, incorrect settings
     - **Network problem** - Connection issues, timeouts, DNS resolution failures, firewall blocking requests, or backend service unavailable
   - **Intermittent failure** (passes sometimes): Likely a timing or race condition → Check parallel execution settings and network stability

**Email Tests Failing**:

- Verify the backend email cache endpoint is available at `${TEST_BASE_URL}/v1/robot_email_cache/`
- Check that `ROBOT_EMAIL_ADDRESSES` is configured in Django settings so that the test environment captures emails for the address used in the robot tests

## 📚 Additional Resources

- [Robot Framework Documentation](https://docs.robotframework.org/) - For test framework details
- [TEST_ARCHITECTURE.md](TEST_ARCHITECTURE.md) - Test architecture and coverage information
- [PARALLEL_DATA_SETUP_GUIDE.md](PARALLEL_DATA_SETUP_GUIDE.md) - Comprehensive guide for parallel testing with tag-based data distribution
