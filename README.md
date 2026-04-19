# 🍳 FoodLens

**FoodLens** is an AI-powered Recipe & Meal Planner app, developed as part of the **Mobile Application Design Lab** course at **Daffodil International University**.

This app leverages the **Gemini API** to generate creative recipes, analyze nutritional content
, and deliver personalized weekly meal plans based on user preferences.

---

## 📚 Documentation

For detailed documentation on setup, architecture, dependencies, and configuration, see the [docs folder](docs/README.md):

- **[Getting Started](docs/GETTING_STARTED.md)** - Installation and setup
- **[Project Architecture](docs/PROJECT_ARCHITECTURE.md)** - Code structure and design
- **[Dependencies](docs/DEPENDENCIES.md)** - Packages and usage
- **[API Documentation](docs/API_DOCUMENTATION.md)** - Gemini API guide
- **[Configuration Guide](docs/CONFIGURATION.md)** - Customization options

---

## 🚀 Features

### ✅ Login / Sign-Up

- Secure authentication for personalized access.
- Firebase Authentication (Currently used mock signup and login; as it was showing errors)

---

### ✅ Recipe Generation

- 📸 **Image Input:** Snap or upload ingredient photos for recipe suggestions.
- 🎙️ **Voice Input:** Speak your recipe request (powered by **Whisper** speech-to-text).
- 💬 **Text Input:** Type ingredient names or custom requests.
- ⚡ **Dietary Filters:** Choose from:
  - None
  - Keto
  - Halal
  - High-Protein
  - Nutritious
- 🍽️ **AI Output:**
  - Auto-generated recipe title
  - Ingredients
  - Steps
  - Nutrition info (visualized as a pie chart via **Calorie AI**)
  - AI-generated recipe images

---

### ✅ Weekly Meal Planner

- 🎯 Personalized 7-day meal plan based on selected dietary filters.
- 🧠 Answer 10 MCQs to fine-tune AI meal suggestions.
- 🗓️ Export your meal plan as a **PDF**.

---

### ✅ Profile Section

- 📊 Tracks the total number of recipes generated.
- 📝 Displays a list of previously generated recipe titles.

---

### ✅ About Section

- ℹ️ App information and developer team credits.

---

## 🧠 Tech Stack

| Technology        | Usage                                          |
| ----------------- | ---------------------------------------------- |
| Flutter           | UI Development                                 |
| Provider          | State Management                               |
| SharedPreferences | Local Storage                                  |
| Gemini API        | AI Recipe, Meal Plan, and Nutrition Generation |
| Image Picker      | Camera / Gallery Integration                   |
| Printing Package  | PDF Meal Plan Export                           |

---

## 👨‍💻 Development Team

| Name              |
| ----------------- |
| Ovi Shekh         |
| Junayed Bin Karim |
| Mst. Azra Zerin   |

---

## 🧑‍🏫 Instructor

**Tanjir Ahmed Anik**  
Lecturer, Daffodil International University

---

## 🚀 Quick Start

1. **Clone the repository**

   ```bash
   git clone https://github.com/ovishkh/FoodLens.git
   cd FoodLens
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure API key**
   - Get a Gemini API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Create `lib/config/api_keys.dart` with your key
   - See [API Documentation](docs/API_DOCUMENTATION.md) for details

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Generate Android APK**
   ```bash
   flutter build apk --release
   ```
   The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`
   
For detailed instructions, see [Getting Started Guide](docs/GETTING_STARTED.md)

---

## 📂 Project Structure

```
lib/
├── main.dart
├── config/               # Configuration & API keys
├── constants/            # App-wide constants
├── models/               # Data models
├── screens/              # UI screens
├── services/             # API services
├── widgets/              # Reusable widgets
├── providers/            # State management
└── utils/                # Utilities
```

See [PROJECT_ARCHITECTURE.md](docs/PROJECT_ARCHITECTURE.md) for details.

---

## ⚠️ Notes

- 🎯 This is a **student project** designed for **Android devices only**.
- ☁️ Currently **no cloud-based database** — uses local storage.
- 🔒 API keys are securely handled and **never hardcoded** in the repository...
- 📁 Professional project structure with organized folders and documentation.
- 🛠️ Ready for production development and team collaboration.

---

