# Migration Guide: Local Storage to Supabase

## Overview

This guide provides step-by-step instructions for migrating FoodLens from local storage (SharedPreferences) to Supabase (PostgreSQL + Auth).

**Migration Path**: SharedPreferences → Supabase

---

## Table of Contents

1. [Why Migrate to Supabase](#why-migrate-to-supabase)
2. [Prerequisites](#prerequisites)
3. [Supabase Setup](#supabase-setup)
4. [Dependencies](#dependencies)
5. [Architecture Overview](#architecture-overview)
6. [Implementation Steps](#implementation-steps)
7. [Database Schema](#database-schema)
8. [Code Examples](#code-examples)
9. [Data Migration](#data-migration)
10. [Testing](#testing)
11. [Deployment](#deployment)
12. [Troubleshooting](#troubleshooting)

---

## Why Migrate to Supabase

### Advantages of Supabase

✅ **Open Source**

- Built on PostgreSQL
- Full control over data
- Can self-host if needed

✅ **SQL Queries**

- Powerful SQL capabilities
- Complex queries possible
- Familiar SQL syntax

✅ **Relational Database**

- Relationships between tables
- Foreign keys support
- Complex data modeling

✅ **Real-time Capabilities**

- PostgREST API
- Subscriptions for real-time updates
- WebSocket support

✅ **Row Level Security (RLS)**

- Fine-grained access control
- Built-in database security
- User-based data isolation

✅ **Cost-Effective**

- Free tier is generous
- Pay-as-you-go pricing
- Transparent pricing

### Disadvantages (Considerations)

⚠️ **Learning Curve**: SQL and PostgreSQL knowledge needed
⚠️ **Maintenance**: Need to manage database schema
⚠️ **Configuration**: More setup than Firebase
⚠️ **Scaling**: Manual scaling in some scenarios

---

## Prerequisites

### Before Starting

- ✅ Flutter project set up and running
- ✅ GitHub account (Supabase uses GitHub for signup)
- ✅ Android/iOS configured
- ✅ Test device or emulator ready
- ✅ Git repository initialized (for backup)
- ✅ Basic SQL knowledge recommended

### Required Knowledge

- PostgreSQL basics
- SQL DML/DDL
- REST API concepts
- Authentication flows
- Real-time database concepts

---

## Supabase Setup

### Step 1: Create Supabase Account

1. Go to [Supabase](https://supabase.com)
2. Click **Start Your Project**
3. Sign up with GitHub account
4. Authorize Supabase

### Step 2: Create Project

1. Click **New Project**
2. Enter project name: `foodlens`
3. Create a strong password (save it!)
4. Choose region closest to users
5. Click **Create new project**
6. Wait for project initialization (2-3 minutes)

### Step 3: Get Project Credentials

In **Project Settings** → **General**:

```
URL: https://your-project.supabase.co
Anon Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Service Role Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Save these safely (will need for Flutter app)

### Step 4: Enable Authentication Providers

1. Go to **Authentication** → **Providers**
2. Enable **Email** (already enabled)
3. Enable **Google** (optional):
   - Add Google OAuth credentials
4. Configure redirect URLs:
   - Android: `com.foodlens://login`
   - Web: `http://localhost:3000`

### Step 5: Create Database Tables

Run SQL in **SQL Editor**:

```sql
-- Create users table (extends Supabase auth)
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS full_name TEXT;

-- Create recipes table
CREATE TABLE IF NOT EXISTS recipes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  ingredients TEXT[] NOT NULL,
  steps TEXT[] NOT NULL,
  dietary_preference TEXT,
  calories NUMERIC,
  protein NUMERIC,
  carbs NUMERIC,
  fat NUMERIC,
  image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, id)
);

-- Create meal_plans table
CREATE TABLE IF NOT EXISTS meal_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  dietary_preference TEXT NOT NULL,
  recipes UUID[] NOT NULL,
  start_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, id)
);

-- Create indexes
CREATE INDEX idx_recipes_user_id ON recipes(user_id);
CREATE INDEX idx_recipes_created_at ON recipes(created_at);
CREATE INDEX idx_meal_plans_user_id ON meal_plans(user_id);

-- Enable Row Level Security
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_plans ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can select own recipes"
  ON recipes FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own recipes"
  ON recipes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own recipes"
  ON recipes FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own recipes"
  ON recipes FOR DELETE
  USING (auth.uid() = user_id);

-- Similar policies for meal_plans...
```

---

## Dependencies

### Add Supabase Packages

```yaml
# pubspec.yaml
dependencies:
  supabase_flutter: ^1.10.0
  gotrue: ^1.8.0
  postgrest: ^0.7.0
  realtime_client: ^0.1.0
  google_sign_in: ^6.1.0 # Optional
```

### Install Dependencies

```bash
flutter pub add supabase_flutter
flutter pub add gotrue
flutter pub add postgrest
flutter pub add realtime_client
flutter pub get
```

### Android Configuration

**File**: `android/app/build.gradle.kts`

```kotlin
android {
    compileSdk 34

    defaultConfig {
        minSdk 21
        targetSdk 34
    }
}

dependencies {
    // Supabase requires Java 8+
}
```

**File**: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET" />
</manifest>
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

### New Architecture (Supabase)

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
│ - subscribeToRecipes│
└──────┬──────────────┘
       │
┌──────▼──────────────────────────┐
│  SupabaseService                │
├─────────────────────────────────┤
│ - PostgreSQL operations         │
│ - Real-time subscriptions       │
│ - Authentication                │
└──────┬──────────────────────────┘
       │
┌──────▼──────────────────────────┐
│  Supabase                       │
├─────────────────────────────────┤
│ - PostgreSQL Database           │
│ - Real-time capabilities        │
│ - Authentication (GoTrue)       │
└─────────────────────────────────┘
```

---

## Implementation Steps

### Step 1: Initialize Supabase

Create `lib/config/supabase_config.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
```

### Step 2: Create Supabase Service

Create `lib/services/supabase_service.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Get auth stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Sign up
  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Sign in
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Add recipe
  Future<Map<String, dynamic>> addRecipe(Map<String, dynamic> recipe) async {
    final response = await _client
        .from('recipes')
        .insert({
          'user_id': currentUser!.id,
          ...recipe,
        })
        .select()
        .single();
    return response;
  }

  // Get all recipes
  Future<List<Map<String, dynamic>>> getAllRecipes() async {
    return await _client
        .from('recipes')
        .select()
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false);
  }

  // Subscribe to recipes (real-time)
  Stream<List<Map<String, dynamic>>> subscribeToRecipes() {
    return _client
        .from('recipes')
        .stream(primaryKey: ['id'])
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false)
        .asList()
        .asStream();
  }

  // Update recipe
  Future<void> updateRecipe(String id, Map<String, dynamic> recipe) async {
    await _client
        .from('recipes')
        .update(recipe)
        .eq('id', id)
        .eq('user_id', currentUser!.id);
  }

  // Delete recipe
  Future<void> deleteRecipe(String id) async {
    await _client
        .from('recipes')
        .delete()
        .eq('id', id)
        .eq('user_id', currentUser!.id);
  }
}
```

### Step 3: Create Provider

Create `lib/providers/supabase_recipe_provider.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:food_lens/models/recipe.dart';
import 'package:food_lens/services/supabase_service.dart';

class SupabaseRecipeProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Subscribe to recipes (real-time)
  void subscribeToRecipes() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription = _supabaseService.subscribeToRecipes().listen(
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

      await _supabaseService.addRecipe(recipe.toJson());
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
    _subscription?.cancel();
    super.dispose();
  }
}
```

### Step 4: Update Main App

Update `lib/main.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:food_lens/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const FoodLensApp());
}

class FoodLensApp extends StatelessWidget {
  const FoodLensApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => SupabaseRecipeProvider()
                ..subscribeToRecipes(),
            ),
          ],
          child: MaterialApp(
            home: session != null ? const HomeScreen() : const LoginScreen(),
          ),
        );
      },
    );
  }
}
```

---

## Database Schema

### Recipes Table

```sql
CREATE TABLE recipes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  ingredients TEXT[] NOT NULL,         -- Array of ingredient strings
  steps TEXT[] NOT NULL,               -- Array of instruction strings
  dietary_preference TEXT,              -- keto, halal, etc.
  calories NUMERIC,
  protein NUMERIC,
  carbs NUMERIC,
  fat NUMERIC,
  image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, id)
);

-- Example inserting recipe:
-- INSERT INTO recipes (user_id, title, ingredients, steps, dietary_preference)
-- VALUES (
--   'user-id',
--   'Pasta',
--   ARRAY['pasta', 'tomato sauce', 'basil'],
--   ARRAY['Boil pasta', 'Add sauce', 'Serve'],
--   'None'
-- );
```

### Meal Plans Table

```sql
CREATE TABLE meal_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  dietary_preference TEXT NOT NULL,
  monday_recipe UUID REFERENCES recipes(id),
  tuesday_recipe UUID REFERENCES recipes(id),
  wednesday_recipe UUID REFERENCES recipes(id),
  thursday_recipe UUID REFERENCES recipes(id),
  friday_recipe UUID REFERENCES recipes(id),
  saturday_recipe UUID REFERENCES recipes(id),
  sunday_recipe UUID REFERENCES recipes(id),
  start_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, id)
);
```

---

## Code Examples

### Example: Fetch and Display Recipes

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SupabaseRecipeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        return ListView.builder(
          itemCount: provider.recipes.length,
          itemBuilder: (context, index) {
            final recipe = provider.recipes[index];
            return RecipeCard(recipe: recipe);
          },
        );
      },
    );
  }
}
```

### Example: Real-time Updates

```dart
@override
void initState() {
  super.initState();
  // Automatically subscribes to real-time updates
  context.read<SupabaseRecipeProvider>().subscribeToRecipes();
}
```

### Example: Add Recipe with Real-time Sync

```dart
Future<void> addNewRecipe() async {
  final recipe = Recipe(
    title: 'Pasta Carbonara',
    ingredients: ['Pasta', 'Eggs', 'Bacon'],
    steps: ['Cook pasta', 'Make sauce', 'Mix together'],
    dietaryPreference: 'None',
  );

  // Add to Supabase (real-time subscription will auto-update UI)
  await context.read<SupabaseRecipeProvider>().addRecipe(recipe);
}
```

---

## Data Migration

### Strategy: Dual-Write During Transition

```dart
// During migration period, write to both
Future<void> addRecipe(Recipe recipe) async {
  // Write to Supabase (new system)
  try {
    await _supabaseService.addRecipe(recipe);
  } catch (e) {
    print('Supabase write failed: $e');
    // Fall back to local storage if needed
    await _localService.addRecipe(recipe);
  }

  // Also keep local copy for offline
  await _localService.addRecipe(recipe);
}
```

### Migration Script

```dart
Future<void> migrateFromSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  final recipeData = prefs.getString('recipes');

  if (recipeData != null) {
    final List<dynamic> recipes = jsonDecode(recipeData);

    for (var recipe in recipes) {
      try {
        await SupabaseService().addRecipe(recipe);
        print('Migrated: ${recipe['title']}');
      } catch (e) {
        print('Migration error: $e');
      }
    }

    // Clear local storage after successful migration
    await prefs.remove('recipes');
    print('Migration complete!');
  }
}
```

---

## Testing

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('SupabaseService', () {
    late MockSupabaseClient mockClient;
    late SupabaseService service;

    setUp(() {
      mockClient = MockSupabaseClient();
      service = SupabaseService(client: mockClient);
    });

    test('addRecipe creates new recipe', () async {
      final recipe = {'title': 'Test Recipe', 'ingredients': ['test']};

      when(mockClient.from('recipes').insert(any))
          .thenAnswer((_) async => recipe);

      expect(await service.addRecipe(recipe), isNotNull);
    });
  });
}
```

### Integration Tests

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full recipe flow', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodLensApp());

    // Sign in
    await tester.tap(find.byIcon(Icons.email));
    await tester.pumpAndSettle();

    // Add recipe
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify recipe appears
    expect(find.byType(RecipeCard), findsWidgets);
  });
}
```

---

## Deployment

### Pre-Deployment Checklist

- ✅ Backup all data
- ✅ Test with staging database
- ✅ Configure Row Level Security (RLS)
- ✅ Set up database backups
- ✅ Read Supabase pricing
- ✅ Plan migration window

### Environment Configuration

Create `lib/config/env_config.dart`:

```dart
class EnvConfig {
  static const bool useSupabase = true;

  static const String supabaseUrl =
    String.fromEnvironment('SUPABASE_URL',
      defaultValue: 'https://your-project.supabase.co');

  static const String supabaseAnonKey =
    String.fromEnvironment('SUPABASE_ANON_KEY',
      defaultValue: 'YOUR_ANON_KEY');
}
```

### Production Considerations

```
1. Enable Row Level Security
2. Set up database backups (automatic)
3. Monitor database usage
4. Set up alerts
5. Plan disaster recovery
```

---

## Troubleshooting

### Issue: Authentication Failed

```
ERROR: Invalid login credentials
```

**Solution**:

```dart
try {
  await supabaseService.signIn(email, password);
} on AuthException catch (e) {
  print('Auth error: ${e.message}');
}
```

### Issue: Permission Denied (RLS)

```
ERROR: new row violates row-level security policy
```

**Check RLS policy**:

```sql
SELECT * FROM pg_policies
WHERE tablename = 'recipes';
```

### Issue: Real-time Not Working

```dart
// Ensure subscription is active
if (_subscription == null) {
  subscribeToRecipes();
}

// Check Supabase realtime is enabled
// Settings → Replication → Enable publication
```

### Issue: Connection Timeout

```dart
// Increase timeout and retry
final response = await _client
    .from('recipes')
    .select()
    .timeout(Duration(seconds: 10));
```

---

## Performance Optimization

### Database Indexing

```sql
-- These are already created, but you can add more
CREATE INDEX idx_recipes_user_created
  ON recipes(user_id, created_at DESC);

CREATE INDEX idx_recipes_dietary
  ON recipes(user_id, dietary_preference);
```

### Query Optimization

```dart
// Select only needed columns
.select('id, title, ingredients, created_at')

// Use pagination
.range(0, 20)

// Add ordering
.order('created_at', ascending: false)
```

### Caching

```dart
// Cache locally for offline access
Future<void> cacheRecipes(List<Recipe> recipes) async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = jsonEncode(recipes);
  await prefs.setString('cached_recipes', encoded);
}
```

---

## Offline Support

```dart
class OfflineService {
  Future<List<Recipe>> getRecipesOffline() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_recipes');
    if (cached != null) {
      return (jsonDecode(cached) as List)
          .map((r) => Recipe.fromJson(r))
          .toList();
    }
    return [];
  }

  Future<void> syncWhenOnline() {
    // Sync offline changes when connection restored
  }
}
```

---

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Real-time Subscriptions](https://supabase.com/docs/guides/realtime)

---

## Next Steps

1. Create Supabase account and project
2. Set up database and authentication
3. Install dependencies
4. Implement Supabase services
5. Create data migration plan
6. Test thoroughly
7. Execute migration
8. Monitor and optimize
9. Sunset SharedPreferences

---

**Document Version**: 1.0
**Last Updated**: March 13, 2024
**Status**: Ready for Implementation
