# Code Quality and Linting Guide

This project includes automated linting and formatting for code quality.

## Tools

- **Robocop** - Robot Framework linter and formatter (v6.0+, includes Robotidy)
- **Ruff** - Fast Python linter and formatter
- **ShellCheck** - Shell script linter
- **shfmt** - Shell script formatter

## Quick Start

### Run Via Docker Menu (Recommended)

```bash
./docker-test.sh  # macOS/Linux
.\docker-test.ps1  # Windows

# Select options:
#   19. Lint Python Code (Ruff)
#   20. Format Python Code (Ruff)
#   21. Check Python Formatting (Ruff)
#   22. Lint Robot Framework Files (Robocop)
#   23. Lint Shell Scripts (ShellCheck)
#   24. Format Shell Scripts (shfmt)
#   25. Run All Linters
#   26. Run All Formatters
#   27. Format Robot Framework Files (Robocop)
#   28. Format Keywords to Title Case (Robocop)
```

## Configuration

### Python (`.ruff.toml`)

- Target: Python 3.12+
- Line length: 120 characters
- Rules: Essential errors and warnings only (E, F, W)
- Mode: Permissive - focuses on critical issues

### Robot Framework (`.robocop.toml`)

- Target: Robot Framework 7.3.2+
- Mode: Permissive - disables overly strict rules
- Formatter: Title Case keywords (e.g., "User Logs In")
- Disabled: Documentation requirements, length checks, style warnings

### Shell Scripts (`.shellcheckrc`)

- Mode: Permissive
- Allows intentional patterns
- Focuses on actual bugs, not style

## CI/CD Integration

Linting runs automatically in GitHub Actions (PERMISSIVE MODE):
- Warnings displayed but don't block builds
- Reports uploaded as artifacts
- Easy to review without disrupting workflow

**Recommended:** Use Docker menu (works with any IDE, no setup needed)

## Keyword Naming Convention

**Title Case** is the standard (e.g., "User Logs In With Credentials"):
- Each word capitalized
- Robot Framework recommended convention
- Applied via Robocop's RenameKeywords formatter

Use menu option 28 to format keywords to Title Case.

## Troubleshooting

**Want to run linting on git commit?** (Optional)
```bash
pip install pre-commit
pre-commit install
# Now linting runs automatically on commit
```

## References

- [Robocop Documentation](https://robocop.readthedocs.io/)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [ShellCheck Wiki](https://www.shellcheck.net/)
