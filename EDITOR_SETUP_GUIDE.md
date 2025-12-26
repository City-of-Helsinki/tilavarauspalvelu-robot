# Simple Local Setup - Varaamo Tests with IDE

🎯 **Goal:** Running tests with visible browser using IDE (Cursor or VS Code)

The Robocorp Code extension handles ALL Python/environment setup automatically.

## 📦 Prerequisites

- **IDE** - Cursor or VS Code
  - **Cursor** - [Download here](https://cursor.com/)
  - **VS Code** - [Download here](https://code.visualstudio.com/)

## 🚀 Setup

### Step 1: Install IDE Extension

1. Open Cursor or VS Code
2. Go to Extensions
3. Search for: **"Robocorp"**
4. Install the **Robocorp Code** extension

This automatically installs Python, Robot Framework, and all dependencies!

📖 **More info:** [Robocorp Quickstart Guide](https://sema4.ai/docs/automation/quickstart-guide)

### Recommended: Install RobotFramework Language Server Extension

For enhanced Robot Framework language support (autocomplete, syntax highlighting, go-to-definition), also install:

1. Search for: **"Robot Framework Language Server"**
2. Install the extension by **Robocorp**

🔗 **Extension Links:**

- [Cursor Marketplace](https://marketplace.cursorapi.com/items/?itemName=robocorp.robotframework-lsp)
- [GitHub Repository](https://github.com/robocorp/robotframework-lsp)

This extension provides intelligent code completion, keyword documentation, and debugging support for `.robot` files.

### Step 2: Open Project in IDE

1. Open Cursor or VS Code
2. Go to **File → Open Folder**
3. Select the project directory
4. Wait for **"Environment ready"** notification (~2-3 minutes first time)

When your IDE opens, the Robocorp Code extension will automatically detect the `conda.yaml` file and set up the environment.

### Step 3: Add Your Secrets

Create `TestSuites/Resources/.env` file with your secrets:

```env
WAF_BYPASS_SECRET=your_secret_here
ROBOT_API_TOKEN=your_token_here
DJANGO_ADMIN_PASSWORD=your_password_here
```

> **📝 Where to get these secrets:**  
> See [SETUP_GUIDE.md](SETUP_GUIDE.md) for details on acquiring the required secrets.

## 🎮 Running Tests with Visible Browser

To see the browser during test execution, you need to manually set `headless=false` in `TestSuites/Resources/devices.robot` for the browser you want to use.

Open `TestSuites/Resources/devices.robot` and change `headless=true` to `headless=false` for the specific browser setup you're testing with (desktop, Firefox, WebKit/iPhone, or Android).

### Run Entire Test Suite

1. Open any test suite file (e.g., `Tests_user_desktop_FI.robot`) in the editor
2. At the top of the editor, you'll see: **Run Suite | Debug Suite | Load in Interactive Console**
3. Click **Run Suite** to execute all tests in the suite
4. Browser opens and you can watch the test!

### Run Specific Test Case

1. Open the test file in the editor
2. Navigate to the specific test case you want to run
3. Click the small **▶️** button that appears above the test case
4. Browser opens and you can watch the test!

## 📊 Viewing Results

After tests open `output/report.html` manually.

## 🚨 Quick Troubleshooting

- **Extension doesn't recognize project?** - Ensure `conda.yaml` exists in project root and reload IDE window
- **Browser doesn't appear?** - Check that `headless=false` is set in `TestSuites/Resources/devices.robot`
- **Tests fail to start?** - Wait for **"Environment ready"** notification

## ⌨️ Useful Command Palette Commands

Open command palette: **Cmd+Shift+P** (Mac) or **Ctrl+Shift+P** (Windows/Linux)

Useful commands for troubleshooting and development:

1. **Robocorp: Clear Robocorp (RCC) environments and restart Robocorp Code**
   - Clears RCC environments and restarts the Robocorp extension
   - Use when environment setup seems corrupted or extension behaves unexpectedly

2. **Robocorp: Terminal with Task Package (Robot) environment**
   - Opens a terminal with the Robot Framework environment activated
   - Useful for running Robot Framework commands manually or debugging

## 📚 Related Documentation

- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Detailed setup instructions and secret acquisition
- [PARALLEL_DATA_SETUP_GUIDE.md](PARALLEL_DATA_SETUP_GUIDE.md) - Running tests in parallel
- [TEST_ARCHITECTURE.md](TEST_ARCHITECTURE.md) - Understanding the test structure
