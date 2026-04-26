# Cal AI Development Checklist

Use this checklist to ensure everything is properly configured before pushing to GitHub or starting active development.

---

## ✅ Pre-Development Setup

### Environment Setup

- [ ] Flutter SDK installed (version 3.7.2+)
- [ ] Dart installed (comes with Flutter)
- [ ] Git installed and configured
- [ ] IDE/Editor set up (VS Code, Android Studio, etc.)
- [ ] Android SDK configured (for Android development)
- [ ] Xcode configured (for iOS development)

### Project Initialization

- [ ] Project cloned/downloaded successfully
- [ ] Dependencies installed: `flutter pub get`
- [ ] No build errors: `flutter analyze`
- [ ] Folder structure confirmed
- [ ] All files present and readable

---

## 🔑 API Configuration

### Gemini API Setup

- [ ] Google Cloud project created
- [ ] Generative Language API enabled
- [ ] API key generated from [Google AI Studio](https://makersuite.google.com/app/apikey)
- [ ] Created `lib/config/api_keys.dart` with API key
- [ ] Verified `api_keys.dart` is in `.gitignore`
- [ ] Tested API connectivity (optional)

---

## 👥 Team Information

### Verify Team Data

- [ ] Team member names correct in `README.md`
- [ ] Team member names correct in `lib/screens/about.dart`
- [ ] Instructor name correct (Tanjir Ahmed Anik)
- [ ] Profile name updated if needed
- [ ] No old credentials remain in code

---

## 📚 Documentation Review

### Read Essential Documentation

- [ ] Read `docs/GETTING_STARTED.md`
- [ ] Read `docs/PROJECT_ARCHITECTURE.md`
- [ ] Read `docs/DEPENDENCIES.md`
- [ ] Read `docs/API_DOCUMENTATION.md`
- [ ] Read `docs/CONFIGURATION.md`
- [ ] Read `.github/CODE_OF_CONDUCT.md`
- [ ] Read `.github/CONTRIBUTING.md`

---

## 🏗️ Project Structure

### Verify File Organization

- [ ] `lib/config/` directory exists
- [ ] `lib/constants/` directory exists
- [ ] `lib/providers/` directory exists
- [ ] `lib/models/` contains data models
- [ ] `lib/screens/` contains UI screens
- [ ] `lib/services/` contains business logic
- [ ] `lib/widgets/` contains reusable components
- [ ] `lib/utils/` contains utilities
- [ ] `docs/` folder contains all documentation
- [ ] `.github/` folder contains policy files

---

## 🔒 Security Checks

### Verify No Sensitive Data in Repository

- [ ] No API keys hardcoded in source files
- [ ] No passwords in configuration
- [ ] No personal information exposed
- [ ] `.gitignore` includes `lib/config/api_keys.dart`
- [ ] `.gitignore` includes `.env` files
- [ ] `.gitignore` includes `*.key` files
- [ ] Verified with: `git status`

---

## 📝 File Verification

### Android Configuration

- [ ] `android/app/build.gradle.kts` namespace: `com.calai`
- [ ] `android/app/build.gradle.kts` app ID: `com.calai`
- [ ] `android/app/src/main/kotlin/com/calai/MainActivity.kt` exists
- [ ] Old `com.example.cal_ai_app` directory removed

### Web Configuration

- [ ] `web/index.html` title: "Cal AI"
- [ ] `web/manifest.json` names: "Cal AI"

### Dart/Flutter Configuration

- [ ] `pubspec.yaml` package name: `cal_ai`
- [ ] `pubspec.yaml` description mentions Cal AI
- [ ] `test/widget_test.dart` imports correct package

---

## 🧪 Build & Test

### Build Verification

- [ ] `flutter clean` executed
- [ ] `flutter pub get` executed successfully
- [ ] `flutter analyze` shows no errors
- [ ] `flutter pub outdated` checked (optional)
- [ ] Application builds for Android: `flutter build apk`
- [ ] Application builds for iOS (if applicable): `flutter build ios`
- [ ] Application runs: `flutter run`

### Functionality Testing

- [ ] App starts without errors
- [ ] Splash screen displays
- [ ] Navigation works
- [ ] About screen shows correct team info
- [ ] Profile screen displays correctly
- [ ] Buttons and UI respond to taps

---

## 🌳 Git Configuration

### Before Initial Commit

- [ ] Git repository initialized: `git init`
- [ ] Git user name configured: `git config user.name "Your Name"`
- [ ] Git user email configured: `git config user.email "your.email@example.com"`
- [ ] `.gitignore` reviewed and verified
- [ ] `pubspec.lock` included in git
- [ ] `analysis_options.yaml` preserved

### Commit Preparation

- [ ] All changes staged: `git add .`
- [ ] Verified staged files: `git status`
- [ ] Commit message prepared
- [ ] `.git` folder exists and valid

---

## 🔗 GitHub Setup (Before Push)

### GitHub Repository

- [ ] GitHub account created/verified
- [ ] Repository created at `ovishkh/Cal AI`
- [ ] Repository is empty (no README, .gitignore, LICENSE)
- [ ] Branch name verified: `main` or `master`
- [ ] Repository description set
- [ ] Topics added: flutter, ai, recipe, meal-planner

### Remote Configuration

- [ ] Remote added: `git remote add origin https://github.com/ovishkh/Cal AI.git`
- [ ] Remote verified: `git remote -v`

---

## 🚀 Deployment Checklist

### First Commit

- [ ] `flutter clean` executed
- [ ] `flutter pub get` executed
- [ ] All files added: `git add .`
- [ ] Initial commit made: `git commit -m "Initial professional restructuring"`
- [ ] Commit verified: `git log --oneline`

### Branch & Push

- [ ] Branch created: `git checkout -b your-name-branch`
- [ ] Changes committed to new branch
- [ ] Branch pushed: `git push -u origin your-name-branch`
- [ ] Pull request created on GitHub

---

## 📋 Development Start

### Before Starting Features

- [ ] Development environment fully set up
- [ ] API key configured and working
- [ ] All documentation read
- [ ] Git repository initialized
- [ ] Feature branch created
- [ ] IDE configured with linting/formatting

### Code Quality

- [ ] Follow Flutter style guide
- [ ] Run `flutter format .` before committing
- [ ] Add meaningful comments to code
- [ ] Follow provider pattern for state management
- [ ] Write descriptive commit messages

---

## 🐛 Troubleshooting

### If errors occur:

- [ ] Check `docs/GETTING_STARTED.md` Troubleshooting section
- [ ] Check `docs/API_DOCUMENTATION.md` for API issues
- [ ] Review `.github/CONTRIBUTING.md` for guidelines
- [ ] Create detailed error notes in commit

---

## ✨ Final Verification

### Before Sharing with Team

- [ ] Run: `flutter clean`
- [ ] Run: `flutter pub get`
- [ ] Run: `flutter analyze`
- [ ] Run: `flutter run`
- [ ] Verify app launches without errors
- [ ] Test basic functionality
- [ ] Review all documentation links work
- [ ] Confirm no sensitive data in repository
- [ ] Verify git history is clean

---

## 📞 Quick Reference

| Task           | Command                        | Docs                    |
| -------------- | ------------------------------ | ----------------------- |
| Install deps   | `flutter pub get`              | GETTING_STARTED.md      |
| Run app        | `flutter run`                  | GETTING_STARTED.md      |
| Check quality  | `flutter analyze`              | GETTING_STARTED.md      |
| Format code    | `flutter format .`             | PROJECT_ARCHITECTURE.md |
| Add dependency | `flutter pub add pkg_name`     | DEPENDENCIES.md         |
| Initialize git | `git init`                     | CONTRIBUTING.md         |
| Create branch  | `git checkout -b feature/name` | CONTRIBUTING.md         |
| Commit changes | `git commit -m "message"`      | CONTRIBUTING.md         |

---

## 🎯 Completion Status

| Item                   | Status |
| ---------------------- | ------ |
| Environment Setup      | [ ]    |
| API Configuration      | [ ]    |
| Team Information       | [ ]    |
| Documentation Review   | [ ]    |
| Structure Verification | [ ]    |
| Security Checks        | [ ]    |
| Build & Test           | [ ]    |
| Git Configuration      | [ ]    |
| GitHub Setup           | [ ]    |
| Deployment             | [ ]    |
| Final Verification     | [ ]    |

---

**Checklist Version**: 1.0  
**Last Updated**: March 13, 2024  
**Status**: Ready for Use

Print this checklist and check off items as you complete them for a clear record of your setup progress.
