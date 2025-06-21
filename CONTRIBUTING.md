# Contributing to YouTube Music Downloader Pro

Thank you for your interest in contributing to YouTube Music Downloader Pro! We welcome contributions from the community and are grateful for your support.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Pull Request Process](#pull-request-process)
- [Issue Guidelines](#issue-guidelines)
- [Community Guidelines](#community-guidelines)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Getting Started

### Prerequisites

- Python 3.8 or higher
- Git
- Basic knowledge of Python and tkinter (for GUI contributions)

### Setting up Development Environment

1. **Fork the repository**
   ```bash
   # Click the "Fork" button on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/yt-music-downloader.git
   cd yt-music-downloader
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   
   # On Windows
   venv\Scripts\activate
   
   # On macOS/Linux
   source venv/bin/activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
    ```

4. **Test the setup**
   ```bash
   python src/cli_main.py  # Test CLI version
   python src/gui_main.py  # Test GUI version
   ```

## How to Contribute

### Types of Contributions

We welcome various types of contributions:

-  **Bug fixes**
-  **New features**
-  **Documentation improvements**
-  **Tests**
-  **UI/UX improvements**
- **Performance optimizations**
-  **Translations/Internationalization**

### Before You Start

1. **Check existing issues** - Look for existing issues or discussions
2. **Create an issue** - For new features or significant changes
3. **Get feedback** - Discuss your approach before implementing
4. **Small PRs** - Keep pull requests focused and manageable

## Development Setup

### Project Structure
```
youtubevideodownloader/
├── 📁 src/                     # Source code
│   ├── 🐍 gui_main.py          # GUI application (main)
│   └── 🐍 cli_main.py          # Command-line interface
├── 📁 assets/                  # Application resources
│   ├── 🖼️ icon.png             # Application icon
│   └── 🖼️ logo.jpeg            # Logo image
├── 📁 packaging/               # Build configurations
│   └── 📁 windows/             # Windows-specific build
│       ├── 🦇 build.bat        # Build script
│       └── 🖼️ logo.ico         # Windows icon
├── 📁 download/                # Default download folder
├── 📄 requirements.txt         # Python dependencies
├── 📄 README.md                # This file
├── 📄 CODE_OF_CONDUCT.md       # Community guidelines
├── 📄 CONTRIBUTING.md          # Contribution guide
└── 📄 .gitignore               # Git ignore rules
```
<!-- 
### Running Tests

```bash
# Run all tests
python -m pytest tests/

# Run with coverage
python -m pytest tests/ --cov=src/

# Run specific test file
python -m pytest tests/test_cli.py
``` -->

<!-- ### Development Commands

```bash
# Format code
black src/ tests/

# Lint code
flake8 src/ tests/

# Type checking
mypy src/

# Check all (recommended before committing)
black src/ tests/ && flake8 src/ tests/ && mypy src/ && pytest tests/
``` -->

## Coding Standards

### Python Style Guide

- Follow [PEP 8](https://pep8.org/) style guide
- Use [Black](https://black.readthedocs.io/) for code formatting
- Maximum line length: 88 characters
- Use type hints where possible

### Code Quality

```python
# Good example
def download_and_convert(video_url: str, out_folder: str) -> bool:
    """
    Download YouTube video and convert to MP3.
    
    Args:
        video_url: YouTube video URL
        out_folder: Output directory path
        
    Returns:
        True if successful, False otherwise
        
    Raises:
        ValueError: If URL is invalid
        OSError: If output directory is not writable
    """
    try:
        # Implementation here
        return True
    except Exception as e:
        logger.error(f"Download failed: {e}")
        return False
```

### Commit Message Format

Use conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

Examples:
```
feat(gui): add progress bar for downloads
fix(cli): handle invalid URL input gracefully
docs(readme): update installation instructions
```

## Pull Request Process

### Before Submitting

1. **Update your fork**
   ```bash
   git pull
   ```

2. **Create feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Write clean, documented code
   - Add tests for new functionality
   - Update documentation if needed

<!-- 4. **Test thoroughly**
   ```bash
   # Run tests
   pytest tests/
   
   # Test both CLI and GUI versions
   python src/cli_main.py
   python src/gui_main.py
   ``` -->

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new download feature"
   ```

### Submitting the PR

1. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request**
   - Use descriptive title
   - Fill out the PR template
   - Link related issues
   - Add screenshots for UI changes

3. **PR Requirements**
   - [ ] Code follows style guidelines
   - [ ] Tests pass
   - [ ] Documentation updated
   - [ ] No breaking changes (or clearly documented)
   - [ ] Respects legal/ethical guidelines

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Other (please describe)

## Testing
- [ ] Tested CLI version
- [ ] Tested GUI version
- [ ] Added/updated tests
- [ ] All tests pass

## Screenshots (if applicable)
[Add screenshots for UI changes]

## Checklist
- [ ] Code follows project standards
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No sensitive information exposed
```

## Issue Guidelines

### Bug Reports

Use this template for bug reports:

```markdown
**Bug Description**
Clear description of the bug

**Steps to Reproduce**
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected Behavior**
What you expected to happen

**Screenshots**
If applicable, add screenshots

**Environment:**
- OS: [e.g. Windows 10, Ubuntu 20.04]
- Python Version: [e.g. 3.9.2]
- Application Version: [e.g. 1.2.0]

**Additional Context**
Any other context about the problem
```

### Feature Requests

```markdown
**Feature Description**
Clear description of the feature

**Problem it Solves**
What problem does this feature solve?

**Proposed Solution**
How do you envision this working?

**Alternatives Considered**
Alternative solutions you've considered

**Additional Context**
Any other context or screenshots
```

## Community Guidelines

### Best Practices

- **Be respectful** - Treat all community members with respect
- **Be constructive** - Provide helpful feedback and suggestions
- **Stay on topic** - Keep discussions relevant to the project
- **Follow legal guidelines** - Respect copyright and terms of service

### Getting Help

- **GitHub Discussions** - For questions and general discussion
- **Issues** - For bug reports and feature requests

### Recognition

Contributors will be recognized:
- In the project README
- In release notes
- Special badges for significant contributions

## Additional Resources

### Learning Resources
- [Python Documentation](https://docs.python.org/)
- [tkinter Tutorial](https://docs.python.org/3/library/tkinter.html)
- [Git Handbook](https://guides.github.com/introduction/git-handbook/)

### Development Tools
- [Visual Studio Code](https://code.visualstudio.com/)
- [PyCharm](https://www.jetbrains.com/pycharm/)
- [Black Formatter](https://black.readthedocs.io/)

## Thank You!

Your contributions help make this project better for everyone. We appreciate your time and effort in making YouTube Music Downloader Pro a great tool for the community!

---

*Questions? Feel free to open an issue or start a discussion!*