# GitHub Instructions for FoodLens

## Overview

This document provides guidelines for using GitHub to contribute to and manage the FoodLens project.

## Repository Information

- **Repository Name**: FoodLens
- **Owner**: Ovi Shekh (@ovishkh)
- **URL**: https://github.com/ovishkh/FoodLens
- **License**: Proprietary (Copyright © 2024 Ovi Shekh)

---

## Getting Started

### Clone the Repository

```bash
# Using SSH
git clone git@github.com:ovishkh/FoodLens.git

# Using HTTPS
git clone https://github.com/ovishkh/FoodLens.git

cd FoodLens
```

### Set Up Git Configuration

```bash
# Set user name and email
git config user.name "Your Name"
git config user.email "your.email@example.com"

# For local configuration only (recommended)
git config --local user.name "Your Name"
git config --local user.email "your.email@example.com"
```

---

## Branching Strategy

### Branch Naming Convention

```
<type>/<description>

Types:
- feature/    - New features
- bugfix/     - Bug fixes
- docs/       - Documentation updates
- refactor/   - Code refactoring
- improve/    - Performance improvements
- test/       - Test additions

Examples:
- feature/recipe-generation
- bugfix/api-timeout-issue
- docs/update-readme
- refactor/provider-structure
```

### Creating a Branch

```bash
# Update main branch
git checkout main
git pull origin main

# Create and checkout new branch
git checkout -b feature/your-feature-name
```

---

## Making Changes

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>

Types:
- feat:     New feature
- fix:      Bug fix
- docs:     Documentation changes
- style:    Code style changes (formatting)
- refactor: Code refactoring
- test:     Test additions/changes
- chore:    Build, dependency updates

Example:
feat(recipe): add ingredient analysis feature

Add new capability to analyze ingredients from images
using the Gemini Vision API.

Closes #123
```

### Code Style

- Follow Flutter/Dart style guides
- Use `flutter format` to format code:
  ```bash
  flutter format .
  ```
- Run analysis before committing:
  ```bash
  flutter analyze
  ```

### Committing Changes

```bash
# Stage changes
git add .

# View staged changes
git status

# Commit with message
git commit -m "feat(recipe): add ingredient analysis feature"

# View commit history
git log --oneline
```

---

## Pushing Changes

### Push to Remote

```bash
# Push to remote (first time on new branch)
git push -u origin feature/your-feature-name

# Subsequent pushes
git push origin feature/your-feature-name
```

### Force Push (Use with Caution)

```bash
# Only use if necessary (e.g., to fix commit history)
git push -f origin feature/your-feature-name
```

---

## Pull Requests (PRs)

### Creating a Pull Request

1. **Push your branch** to GitHub
2. **Go to GitHub repository**
3. **Click "New Pull Request"** button
4. **Select your branch** as the source
5. **Fill out the PR template** with:
   - Description of changes
   - Related issues (use `Closes #123`)
   - Type of change indicator
   - Testing information
   - Screenshots (if applicable)
6. **Request reviewers** (usually @ovishkh)
7. **Click "Create Pull Request"**

### PR Template Usage

When creating a PR, use the provided template at `.github/pull_request_template.md`:

- Check all applicable checkboxes
- Be descriptive about changes
- Link related issues
- Add test results
- Request appropriate reviewers

### PR Guidelines

- Keep PRs focused on single feature/fix
- Keep PR title descriptive and under 50 characters
- Provide clear description of what and why
- Link related issues
- Ensure all CI checks pass
- Request review from maintainers
- Address review comments promptly

---

## Issues

### Creating Issues

1. **Click "Issues"** tab on GitHub
2. **Click "New Issue"** button
3. **Choose issue type**:
   - Bug report
   - Feature request
   - Documentation
4. **Fill out the template** with:
   - Clear description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Environment details
5. **Add labels** (bug, feature, documentation, etc.)
6. **Submit issue**

### Issue Guidelines

- Use clear, descriptive titles
- Provide steps to reproduce (for bugs)
- Include screenshots when helpful
- Add appropriate labels
- Be respectful and constructive

### Issue Template

Use the template provided at `.github/ISSUE_TEMPLATE.md`:

- Describe the issue clearly
- For bugs: provide reproduction steps
- Include environment information
- Add suggested solutions if applicable

---

## Code Review Process

### Before Requesting Review

- [ ] Code passes `flutter analyze`
- [ ] Code is formatted with `flutter format .`
- [ ] All tests pass locally
- [ ] No merge conflicts
- [ ] Commits are meaningful and descriptive
- [ ] Documentation is updated

### During Review

- Be open to feedback
- Respond to all comments
- Make requested changes promptly
- Re-request review after making changes
- Ask for clarification if needed

### After Approval

- Ensure CI/CD passes
- Squash commits if requested
- Merge PR (if you have permissions)
- Delete branch after merge

---

## Merging

### Squash and Merge

```bash
# Squash commits into one
git rebase -i origin/main

# Push after rebase
git push -f origin feature/your-feature-name
```

### Standard Merge

```bash
# Update main
git checkout main
git pull origin main

# Merge branch
git merge feature/your-feature-name

# Push to remote
git push origin main
```

### Deleting Branch

```bash
# Locally
git branch -d feature/your-feature-name

# Remote
git push origin --delete feature/your-feature-name
```

---

## Syncing Your Fork/Branch

### Update Branch with Latest Main

```bash
# Fetch latest
git fetch origin

# Rebase on main
git rebase origin/main

# Or merge if rebase is problematic
git merge origin/main

# Push updated branch
git push origin feature/your-feature-name
```

---

## Useful Git Commands

```bash
# View commit history
git log --oneline
git log --graph --oneline --all

# View changes
git status
git diff
git diff --staged

# Undo changes
git restore <file>
git reset --soft HEAD~1

# Stash changes
git stash
git stash pop

# Browse history
git show <commit-hash>
git blame <file>
```

---

## Repository Structure

```
FoodLens/
├── .github/
│   ├── pull_request_template.md    # PR template
│   ├── ISSUE_TEMPLATE.md           # Issue template
│   ├── CODE_OF_CONDUCT.md          # Community standards
│   ├── CONTRIBUTING.md             # Contribution guidelines
│   └── SECURITY.md                 # Security policy
├── docs/                           # Documentation
├── lib/                            # Source code
├── android/, ios/, web/            # Platform-specific code
├── test/                           # Tests
├── LICENSE                         # Proprietary license
└── README.md                       # Project overview
```

---

## Release Process

### Creating a Release

1. **Create release branch**:
   ```bash
   git checkout -b release/v1.x.x
   ```

2. **Update version** in `pubspec.yaml`

3. **Update CHANGELOG** (if applicable)

4. **Create PR** for release branch review

5. **After approval, merge** to main

6. **Create GitHub release**:
   - Go to "Releases"
   - Click "Create new release"
   - Add tag (e.g., v1.0.0)
   - Add release notes
   - Publish release

---

## Troubleshooting

### Merge Conflicts

```bash
# View conflicts
git status

# Edit files to resolve conflicts

# After resolving
git add .
git commit -m "Resolve merge conflicts"
```

### Accidentally Committed to Main

```bash
# Create branch from current state
git branch feature/new-feature-name

# Reset main
git reset --hard origin/main
```

### Need to Undo Last Commit

```bash
# Undo and keep changes
git reset --soft HEAD~1

# Undo and discard changes
git reset --hard HEAD~1
```

---

## Important Reminders

⚠️ **DO**:
- ✅ Always pull before pushing
- ✅ Use meaningful commit messages
- ✅ Keep commits atomic (one thing per commit)
- ✅ Review your own code first
- ✅ Test locally before pushing
- ✅ Ask for help if unsure

❌ **DON'T**:
- ❌ Push directly to main branch
- ❌ Force push without discussing
- ❌ Commit sensitive information (use .gitignore)
- ❌ Make unrelated changes in one PR
- ❌ Ignore CI/CD failures
- ❌ Skip testing before PR

---

## Getting Help

- **GitHub Issues**: Create an issue for bugs/features
- **Pull Request Comments**: Ask questions in PR discussions
- **Code Review**: Request review from @ovishkh
- **Documentation**: Check README.md and docs/ folder

---

## Additional Resources

- [GitHub Documentation](https://docs.github.com)
- [Git Documentation](https://git-scm.com/doc)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

---

**Last Updated**: March 13, 2024
**Owner**: Ovi Shekh (@ovishkh)
