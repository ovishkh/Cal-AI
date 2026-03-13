# Migration Guide: Local Storage to Firebase

## Overview

This guide provides step-by-step instructions for migrating FoodLens from local storage (SharedPreferences) to Firebase Realtime Database or Firestore.

**Migration Path**: SharedPreferences → Firebase (Firestore or Realtime DB)

---

## Table of Contents

1. [Why Migrate to Firebase](#why-migrate-to-firebase)
2. [Prerequisites](#prerequisites)
3. [Firebase Setup](#firebase-setup)
4. [Dependencies](#dependencies)
5. [Architecture Overview](#architecture-overview)
6. [Implementation Steps](#implementation-steps)
7. [Code Examples](#code-examples)
8. [Data Migration](#data-migration)
9. [Testing](#testing)
10. [Deployment](#deployment)
11. [Troubleshooting](#troubleshooting)

---

## Why Migrate to Firebase

### Advantages of Firebase

✅ **Cloud Storage**

- No data loss on device deletion
- Access recipes across devices
- Automatic backups

✅ **Real-time Sync**

- Instant updates across devices
- Live collaboration features
- Real-time notifications

✅ **Scale Efficiently**

- Handle millions of users
- Auto-scaling infrastructure
- Pay only for what you use

✅ **Built-in Features**

- Authentication out of the box
- Server-side validation
- Security rules

✅ **Better Analytics**

- Track user behavior
- Performance monitoring
- Crash reporting

### Disadvantages (Considerations)

⚠️ **Costs**: Free tier has limitations
⚠️ **Internet Required**: Need active connection
⚠️ **Data Privacy**: Data stored on Google servers
⚠️ **Dependency**: Relies on Firebase availability

---

## Prerequisites

### Before Starting

- ✅ Flutter project set up and running
- ✅ Google account for Firebase Console
- ✅ Android/iOS configured
- ✅ Test device or emulator ready
- ✅ Git repository initialized (for backup)

### Required Knowledge

- Basic Firebase concepts
- Firestore vs Realtime Database differences
- Authentication flows
- Security rules writing

---

## Firebase Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add Project"
3. Enter project name: `foodlens`
4. Choose region (closest to users)
5. Enable Google Analytics (optional)
6. Create project

### Step 2: Enable Firestore

1. In Firebase Console, go to **Firestore Database**
2. Click **Create Database**
3. Choose **Start in Production Mode** (for testing) or **Test Mode**
4. Select region (same as project)
5. Create

### Step 3: Configure Authentication

1. Go to **Authentication**
2. Click **Get Started**
3. Enable **Email/Password** provider
4. Enable **Google Sign-in** (optional)

### Step 4: Add Android App

1. Go to **Project Settings** → **General**
2. Click **Add App** → **Android**
3. Enter package name: `com.foodlens`
4. Download `google-services.json`
5. Place in `android/app/`

### Step 5: Add iOS App (if needed)

1. Go to **Project Settings** → **General**
2. Click **Add App** → **iOS**
3. Enter bundle ID
4. Download `GoogleService-Info.plist`
5. Place in `ios/Runner/`

---

## Dependencies

### Add Firebase Packages

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.0
  cloud_firestore: ^4.14.0
  firebase_auth: ^4.14.0
  google_sign_in: ^6.1.0 # Optional

dev_dependencies:
  firebase_cli: ^0.11.0 # Optional, for CLI management
```

### Install Dependencies

```bash
flutter pub add firebase_core
flutter pub add cloud_firestore
flutter pub add firebase_auth
flutter pub add google_sign_in
flutter pub get
```

### Android Configuration

**File**: `android/app/build.gradle.kts`

```kotlin
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'com.google.gms.google-services' // Add this
}

android {
    // ... existing config
}

dependencies {
    implementation 'com.google.firebase:firebase-bom:32.7.0'
    implementation 'com.google.firebase:firebase-firestore-ktx'
    implementation 'com.google.firebase:firebase-auth-ktx'
}
```

**File**: `android/build.gradle.kts`

```kotlin
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0' // Add this
    }
}
```

---

## Architecture Overview

### Current Architecture (SharedPreferences)

```
┌─────────────┐
│   Screens   │
└──────┬──────┘
       │
┌──────▼──────────────┐
│  RecipeProvider     │
├─────────────────────┤
│ - recipes[]         │
│ - addRecipe()       │
│ - deleteRecipe()    │
└──────┬──────────────┘
       │
┌──────▼──────────────────────┐
│  SharedPreferences          │
├─────────────────────────────┤
│ - Local device storage only │
└─────────────────────────────┘
```

### New Architecture (Firebase)

```
┌─────────────┐
│   Screens   │
└──────┬──────┘
       │
┌──────▼──────────────┐
│  RecipeProvider     │
├─────────────────────┤
│ - recipes[]         │
│ - addRecipe()       │
│ - deleteRecipe()    │
│ - syncWithFirebase()│
└──────┬──────────────┘
       │
┌──────▼──────────────────────────┐
│  FirebaseService                │
├─────────────────────────────────┤
│ - Firestore operations          │
│ - Real-time listeners           │
│ - Sync logic                    │
└──────┬──────────────────────────┘
       │
┌──────▼──────────────────────┐
│  Firebase Firestore + Auth  │
├─────────────────────────────┤
│ - Cloud storage (scalable)  │
│ - Real-time sync            │
│ - Multi-device sync         │
└─────────────────────────────┘
```

---

## Implementation Steps

### Step 1: Initialize Firebase

Create `lib/config/firebase_config.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
```

Generate `firebase_options.dart` using FlutterFire CLI:

```bash
flutterfire configure
```

### Step 2: Create Firebase Service

Create `lib/services/firebase_service.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get recipes =>
      _firestore.collection('users').doc(_auth.currentUser!.uid).collection('recipes');

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email
  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign in
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // Add recipe
  Future<DocumentReference> addRecipe(Map<String, dynamic> recipe) async {
    return await recipes.add({
      ...recipe,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update recipe
  Future<void> updateRecipe(String recipeId, Map<String, dynamic> recipe) async {
    return await recipes.doc(recipeId).update({
      ...recipe,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete recipe
  Future<void> deleteRecipe(String recipeId) async {
    return await recipes.doc(recipeId).delete();
  }

  // Get all recipes (one-time)
  Future<List<Map<String, dynamic>>> getAllRecipes() async {
    final snapshot = await recipes.get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  // Stream recipes (real-time)
  Stream<List<Map<String, dynamic>>> getRecipesStream() {
    return recipes.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }
}
```

### Step 3: Update Providers

Create `lib/providers/firebase_recipe_provider.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:food_lens/models/recipe.dart';
import 'package:food_lens/services/firebase_service.dart';

class FirebaseRecipeProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Map<String, dynamic>>>? _recipesSubscription;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load recipes with real-time listener
  void loadRecipesStream() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _recipesSubscription = _firebaseService.getRecipesStream().listen(
      (data) {
        _recipes = data.map((json) => Recipe.fromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Add recipe
  Future<void> addRecipe(Recipe recipe) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.addRecipe(recipe.toJson());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _recipesSubscription?.cancel();
    super.dispose();
  }
}
```

### Step 4: Update Main App

Update `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:food_lens/config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
  runApp(const FoodLensApp());
}

class FoodLensApp extends StatelessWidget {
  const FoodLensApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FirebaseRecipeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        home: FirebaseAuth.instance.currentUser != null
            ? const HomeScreen()
            : const LoginScreen(),
      ),
    );
  }
}
```

### Step 5: Set Up Security Rules

**Firestore Security Rules**:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;

      match /recipes/{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

---

## Code Examples

### Example: Migrate Stored Recipes

```dart
Future<void> migrateFromSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  final recipeData = prefs.getString('recipes');

  if (recipeData != null) {
    final List<dynamic> recipes = jsonDecode(recipeData);

    final firebaseService = FirebaseService();

    for (var recipe in recipes) {
      try {
        await firebaseService.addRecipe(recipe);
        print('Migrated recipe: ${recipe['title']}');
      } catch (e) {
        print('Error migrating recipe: $e');
      }
    }

    print('Migration complete!');
  }
}
```

### Example: Sync Listener

```dart
void setupRealtimeSync() {
  FirebaseService().getRecipesStream().listen((recipes) {
    // Update UI automatically
    context.read<FirebaseRecipeProvider>().updateRecipes(recipes);
  });
}
```

---

## Data Migration

### Strategy 1: Manual Migration

```dart
// Run once in your app
Future<void> performMigration() async {
  try {
    final localRecipes = await getRecipesFromSharedPrefs();

    for (var recipe in localRecipes) {
      await FirebaseService().addRecipe(recipe);
    }

    // Clear local storage after successful migration
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recipes');

    print('Migration successful!');
  } catch (e) {
    print('Migration failed: $e');
  }
}
```

### Strategy 2: Dual-Write Pattern (Recommended)

```dart
// Write to both during transition
Future<void> addRecipe(Recipe recipe) async {
  // Write to local storage
  await _localService.addRecipe(recipe);

  // Write to Firebase
  try {
    await _firebaseService.addRecipe(recipe);
  } catch (e) {
    print('Firebase write failed: $e');
    // Continue with local storage
  }
}

// After transition period, read only from Firebase
// and clean up local storage
```

---

## Testing

### Unit Tests

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';

void main() {
  setupFirebaseCoreMocks();

  test('Firebase service adds recipe', () async {
    final service = FirebaseService();
    final recipe = Recipe(title: 'Test Recipe');

    final docRef = await service.addRecipe(recipe.toJson());
    expect(docRef, isNotNull);
  });
}
```

### Integration Tests

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Recipe sync from Firebase', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodLensApp());

    // Wait for Firebase to load
    await tester.pumpAndSettle();

    expect(find.byType(RecipeCard), findsWidgets);
  });
}
```

---

## Deployment

### Before Deploying

✅ Backup all user data
✅ Test with staging database
✅ Run all tests
✅ Check security rules
✅ Monitor Firebase console
✅ Have rollback plan

### Staged Rollout

```
Week 1: Internal testing
Week 2: Beta users (10%)
Week 3: 50% of users
Week 4: 100% rollout
```

### Monitoring

```dart
// Add error tracking
FirebaseAnalytics.instance.logEvent(
  name: 'recipe_sync_error',
  parameters: {'error': error.toString()},
);
```

---

## Troubleshooting

### Issue: Authentication Errors

```
ERROR: User is not authenticated
```

**Solution**:

```dart
if (FirebaseAuth.instance.currentUser == null) {
  // Redirect to login
  Navigator.of(context).pushReplacementNamed('/login');
}
```

### Issue: Firestore Permission Denied

```
ERROR: Missing or insufficient permissions
```

**Solution**: Check Firestore security rules

```
# Verify rules are set correctly
# Test with authenticated user
# Check user UID in database path
```

### Issue: Real-time Updates Not Working

```
# Solution: Ensure listener is maintained
StreamSubscription<List<Recipe>>? subscription;

@override
void initState() {
  subscription = FirebaseService().getRecipesStream().listen(...)
}

@override
void dispose() {
  subscription?.cancel(); // Important!
  super.dispose();
}
```

### Issue: Slow Performance

**Solutions**:

```dart
// Add pagination
Query<Map<String, dynamic>> get recipesQuery =>
    recipes.limit(20).orderBy('createdAt', descending: true);

// Use indexing in Firestore console
// Cache recipes locally
// Optimize document structure
```

---

## Performance Optimization

### Indexing

Create composite indexes in Firestore for:

- `userId` + `createdAt`
- `userId` + `dietaryPreference`
- `userId` + `updatedAt`

### Caching

```dart
// Cache recipes locally for offline access
Future<void> cacheRecipes(List<Recipe> recipes) async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = jsonEncode(recipes);
  await prefs.setString('cached_recipes', encoded);
}
```

### Limiting Data

```dart
// Only fetch needed fields
Query<Map<String, dynamic>> get optimizedRecipes =>
    recipes
        .select(['title', 'ingredients', 'createdAt'])
        .limit(50);
```

---

## Switching Between Local and Firebase

```dart
class StorageFactory {
  static const bool useFirebase = true; // Change this to switch

  static StorageService createStorageService() {
    if (useFirebase) {
      return FirebaseService();
    } else {
      return SharedPreferencesService();
    }
  }
}

// Usage
final storageService = StorageFactory.createStorageService();
```

---

## Rollback Plan

If Firebase migration fails:

1. **Immediate Action**

   ```bash
   git revert <firebase-commit>
   flutter pub remove firebase_core cloud_firestore
   ```

2. **Restore from Backup**

   ```dart
   // Use last known good SharedPreferences data
   ```

3. **Notify Users**
   - Show message about service restoration

---

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Firebase Pricing](https://firebase.google.com/pricing)

---

## Next Steps

1. Set up Firebase project
2. Install dependencies
3. Implement Firebase services
4. Test thoroughly
5. Plan migration timeline
6. Execute migration
7. Monitor performance
8. Decommission SharedPreferences (after verification period)

---

**Document Version**: 1.0
**Last Updated**: March 13, 2024
**Status**: Ready for Implementation
