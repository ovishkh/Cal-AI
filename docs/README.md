# FoodLens Documentation

Welcome to the FoodLens documentation! This folder contains comprehensive guides for developers working on and with FoodLens.

## 📚 Documentation Index

### 1. **[GETTING_STARTED.md](GETTING_STARTED.md)**

Complete setup and installation guide

- Installation requirements
- Project setup steps
- Running the application
- Troubleshooting common issues

### 2. **[PROJECT_ARCHITECTURE.md](PROJECT_ARCHITECTURE.md)**

Understanding the project structure and design patterns

- Directory structure overview
- Architecture layers
- State management approach
- Data flow diagrams
- Design patterns used

### 3. **[DEPENDENCIES.md](DEPENDENCIES.md)**

All dependencies and their usage

- List of all packages
- Package versions and purposes
- How to add/update dependencies
- Troubleshooting dependency issues

### 4. **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)**

Gemini API integration and usage

- API setup and authentication
- Endpoint documentation
- Request/response formats
- Error handling
- Configuration options

### 5. **[CONFIGURATION.md](CONFIGURATION.md)**

App configuration and customization

- Application constants
- Theme customization
- API configuration
- Build settings
- Environment-specific setup

## 🚀 Quick Start

If you're new to FoodLens, follow this order:

1. Start with **GETTING_STARTED.md** to set up your development environment
2. Read **PROJECT_ARCHITECTURE.md** to understand the codebase structure
3. Check **DEPENDENCIES.md** to know what packages are being used
4. Review **API_DOCUMENTATION.md** to understand Gemini API integration
5. Use **CONFIGURATION.md** as a reference for customization

## 📁 Project Structure

```
FoodLens/
├── .github/                    # GitHub-specific files
│   ├── CODE_OF_CONDUCT.md
│   ├── CONTRIBUTING.md
│   └── SECURITY.md
├── docs/                       # Documentation (This folder)
│   ├── GETTING_STARTED.md
│   ├── PROJECT_ARCHITECTURE.md
│   ├── DEPENDENCIES.md
│   ├── API_DOCUMENTATION.md
│   └── CONFIGURATION.md
├── lib/                        # Application source code
│   ├── main.dart
│   ├── config/                 # Configuration files
│   ├── constants/              # App constants
│   ├── models/                 # Data models
│   ├── screens/                # UI screens
│   ├── services/               # Services (API, etc.)
│   ├── widgets/                # Reusable widgets
│   ├── providers/              # State management
│   └── utils/                  # Utility functions
├── test/                       # Unit and widget tests
├── android/                    # Android-specific code
├── ios/                        # iOS-specific code
├── web/                        # Web-specific code
├── pubspec.yaml               # Flutter dependencies
└── README.md                  # Main project README
```

## 🔧 Common Tasks

### How do I...

#### Add a new dependency?

See [DEPENDENCIES.md](DEPENDENCIES.md#adding-a-new-dependency)

#### Change the app theme/colors?

See [CONFIGURATION.md](CONFIGURATION.md#theme-configuration)

#### Set up the Gemini API?

See [API_DOCUMENTATION.md](API_DOCUMENTATION.md#getting-started-with-gemini-api)

#### Understand the app architecture?

See [PROJECT_ARCHITECTURE.md](PROJECT_ARCHITECTURE.md)

#### Configure the app for production?

See [CONFIGURATION.md](CONFIGURATION.md#environment-specific-configuration)

#### Fix a build error?

See [GETTING_STARTED.md](GETTING_STARTED.md#troubleshooting)

## 🛠️ Development Guide

### Before You Start Coding

1. Ensure your development environment is set up (see GETTING_STARTED.md)
2. Understand the project architecture (see PROJECT_ARCHITECTURE.md)
3. Know what packages are available (see DEPENDENCIES.md)
4. Understand how the API works (see API_DOCUMENTATION.md)

### While Coding

- Follow the project structure and naming conventions
- Use the Provider package for state management
- Handle errors gracefully
- Write meaningful commit messages
- Add comments for complex logic

### Before Committing

1. Test your changes thoroughly
2. Ensure code follows Flutter best practices
3. Update documentation if needed
4. Follow the commit message format in CONTRIBUTING.md

## 📖 Key Concepts

### State Management with Provider

FoodLens uses Provider for state management. Read about it in [PROJECT_ARCHITECTURE.md](PROJECT_ARCHITECTURE.md#state-management)

### API Integration

All API calls go through the GeminiApiService. Understand how to use it in [API_DOCUMENTATION.md](API_DOCUMENTATION.md)

### Configuration

App configuration is centralized. See [CONFIGURATION.md](CONFIGURATION.md) for all configurable options.

## 🤝 Contributing

Want to contribute? Check out:

- [.github/CONTRIBUTING.md](../.github/CONTRIBUTING.md) - Contribution guidelines
- [.github/CODE_OF_CONDUCT.md](../.github/CODE_OF_CONDUCT.md) - Community standards
- [.github/SECURITY.md](../.github/SECURITY.md) - Security policy

## 📞 Getting Help

If you have questions:

1. Check the relevant documentation file
2. Search for existing issues on GitHub
3. Create a new issue with detailed information
4. Ask in the discussions section

## 🔗 Useful Links

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Provider Package](https://pub.dev/packages/provider)
- [Google Generative AI](https://ai.google.dev/)
- [Material Design](https://material.io/design)

## 📝 Documentation Standards

When adding new documentation:

1. Use clear, concise language
2. Include code examples where applicable
3. Add a table of contents for longer documents
4. Link to related documentation
5. Keep formatting consistent with existing docs

## 🚀 Tips for Success

1. **Read Before Coding**: Always read the relevant documentation
2. **Follow The Structure**: Maintain the project organization
3. **Test Thoroughly**: Always test changes before committing
4. **Comment Your Code**: Help future developers understand complex logic
5. **Stay Updated**: Keep documentation in sync with code changes

---

**Last Updated**: March 13, 2026
**Documentation Version**: 1.0.0
