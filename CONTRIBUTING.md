# Contributing to Aeye

We love your input! We want to make contributing to Aeye as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

## Pull Requests

Pull requests are the best way to propose changes to the codebase. We actively welcome your pull requests:

1. **Fork** the repo and create your branch from `main`
2. **Add tests** if you've added code that should be tested
3. **Update documentation** if you've changed APIs or added features
4. **Ensure the test suite passes**
5. **Make sure your code follows the existing style**
6. **Issue the pull request**

## Code Style

- Use meaningful variable and function names
- Add comments for complex logic
- Follow bash best practices for shell scripts
- Use consistent indentation (4 spaces)
- Keep functions focused and modular

## Testing

- Add tests for new functionality
- Ensure existing tests still pass
- Test on multiple platforms when possible
- Include edge cases in your tests

## Reporting Bugs

We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/gabibeyo/aeye/issues).

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

## Feature Requests

We use GitHub issues to track feature requests as well. When suggesting a feature:

- Explain the use case
- Describe the expected behavior
- Consider backward compatibility
- Think about the implementation complexity

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/gabibeyo/aeye.git
   cd aeye
   ```

2. **Install dependencies**
   ```bash
   brew install jq  # macOS
   ```

3. **Run tests**
   ```bash
   ./scripts/run-tests.sh
   ```

4. **Start development**
   ```bash
   ./src/claude-monitor.sh
   ```

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## Questions?

Feel free to open an issue with the `question` label if you have any questions about contributing!
