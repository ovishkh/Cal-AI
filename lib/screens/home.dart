import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../widgets/recipe_card.dart';
import '../models/recipe.dart';
import '../services/gemini_api.dart';
import '../utils/app_theme.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Input mode selection
  int _selectedInputMode = 0;
  final List<String> _inputModes = ['Image', 'Text'];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Diet filter options
  String _selectedDiet = 'None';
  final List<String> _dietOptions = [
    'None',
    'Vegan',
    'Nut-free',
    'Vegetarian',
    'Keto',
    'Gluten-free',
    'Dairy-free',
  ];

  // Preparation method options
  String _selectedPreparationMethod = 'Any Method';
  final List<String> _preparationMethods = [
    'Any Method',
    'Steamed',
    'Baked',
    'Slow Cooked',
    'Grilled',
    'Stir Fried',
    'Fried',
    'Raw/Fresh',
  ];

  // Servings options
  int _servings = 2;
  final List<int> _servingOptions = [1, 2, 3, 4, 5, 6, 8, 10, 12];

  // Input data holders
  File? _imageFile;
  final TextEditingController _textInputController = TextEditingController();

  // Processing state and data
  bool _processingImage = false;
  bool _generatingRecipe = false;
  bool _generatingImage = false;
  String _extractedIngredients = '';
  String _statusMessage = '';

  // Recipe data
  Recipe? _currentRecipe;
  List<Recipe> _recentRecipes = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadRecentRecipes();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Add this to ensure we check for a selected recipe when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForSelectedRecipe();
    });
  }

  // Check if there's a recipe selected in AppState
  void _checkForSelectedRecipe() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.selectedRecipe != null) {
      setState(() {
        _currentRecipe = appState.selectedRecipe;
      });
      // Optional: clear the selected recipe from AppState after using it
      // appState.clearSelectedRecipe();

      // Scroll to the recipe card after a short delay to ensure rendering is complete
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent *
                0.3, // Approximate position to scroll to the recipe
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  // Listen for tab changes to update the selected recipe
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkForSelectedRecipe();
  }

  // GeminiAPI service
  final GeminiApiService _geminiApiService = GeminiApiService();

  Future<void> _loadRecentRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = prefs.getStringList('recentRecipes') ?? [];

    setState(() {
      _recentRecipes =
          recipesJson.map((json) => Recipe.fromJson(jsonDecode(json))).toList();
    });
  }

  Future<void> _saveRecentRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson =
        _recentRecipes.map((recipe) => jsonEncode(recipe.toJson())).toList();

    // Keep only last 5 recipes
    if (recipesJson.length > 5) {
      recipesJson.removeRange(5, recipesJson.length);
    }

    await prefs.setStringList('recentRecipes', recipesJson);

    // Update recipe count for profile screen
    int recipeCount = prefs.getInt('recipeCount') ?? 0;
    await prefs.setInt('recipeCount', recipeCount + 1);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _textInputController.clear();
          _extractedIngredients = '';
          _statusMessage = '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  // Step 1: Process image to extract ingredients
  Future<void> _processImageToExtractIngredients() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take or select an image first')),
      );
      return;
    }

    setState(() {
      _processingImage = true;
      _extractedIngredients = '';
      _statusMessage = 'Analyzing ingredients...';
    });

    try {
      // Use Gemini API to extract ingredients from the image
      final ingredients = await _geminiApiService.extractIngredientsFromImage(
        _imageFile!,
      );

      setState(() {
        _extractedIngredients = ingredients;
        _processingImage = false;
        _statusMessage = 'Ingredients detected! Review or edit them below.';
      });

      // Set the extracted ingredients to the text input for user review/edit
      _textInputController.text = ingredients;

      // Switch to text input mode so user can verify and edit ingredients
      setState(() {
        _selectedInputMode = 1;
      });

      // Reset and play animation for input mode change
      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      setState(() {
        _processingImage = false;
        _statusMessage = 'Error extracting ingredients: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error extracting ingredients: $e')),
      );
    }
  }

  // Step 2: Generate recipe from ingredients
  Future<void> _generateRecipe() async {
    String inputData = '';

    // Get input based on selected mode
    if (_selectedInputMode == 0 && _imageFile != null) {
      // First process the image to extract ingredients
      await _processImageToExtractIngredients();
      return; // We'll continue in the next step after user reviews ingredients
    } else if (_selectedInputMode == 1) {
      inputData = _textInputController.text;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide input first')),
      );
      return;
    }

    if (inputData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide valid input')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _generatingRecipe = true;
      _generatingImage = false;
      _statusMessage = 'Generating recipe...';
    });

    try {
      // Use GeminiAPI service to generate recipe
      final recipe = await _geminiApiService.generateRecipe(
        inputData,
        _selectedDiet,
        _selectedPreparationMethod,
        _servings,
      );

      setState(() {
        _generatingRecipe = false;
        _generatingImage = true;
        _statusMessage = 'Creating recipe image...';
      });

      // Recipe is now available, but image generation might still be in progress
      setState(() {
        _currentRecipe = recipe;
        _isLoading = false;
        _statusMessage =
            recipe.imageUrl.startsWith('data:image')
                ? 'Recipe ready with AI-generated image!'
                : 'Recipe ready with stock image';

        // Add to recent recipes and save
        _recentRecipes.insert(0, recipe);
        if (_recentRecipes.length > 5) {
          _recentRecipes.removeLast();
        }
      });

      // Save to local storage
      await _saveRecentRecipes();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _generatingRecipe = false;
        _generatingImage = false;
        _statusMessage = 'Error: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating recipe: $e')));
    }
  }

  Widget _buildInputSection() {
    switch (_selectedInputMode) {
      case 0: // Image
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow:
                      _imageFile != null
                          ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ]
                          : null,
                ),
                child:
                    _imageFile != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Image.file(
                                _imageFile!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              if (_processingImage)
                                Container(
                                  width: double.infinity,
                                  color: Colors.black54,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.0,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Analyzing ingredients...',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        )
                        : Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_camera,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Take a photo of ingredients',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: AppTheme.secondaryButtonStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case 1: // Text
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _textInputController,
                  decoration: InputDecoration(
                    hintText: 'Describe the food or recipe you want...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  maxLines: 5,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (_extractedIngredients.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryLight.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Detected ingredients',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You can edit the detected ingredients above',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          _statusMessage.contains('Error')
                              ? Colors.red[50]
                              : Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            _statusMessage.contains('Error')
                                ? Colors.red[200]!
                                : Colors.green[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _statusMessage.contains('Error')
                              ? Icons.error_outline
                              : Icons.check_circle_outline,
                          color:
                              _statusMessage.contains('Error')
                                  ? Colors.red[700]
                                  : Colors.green[700],
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _statusMessage,
                            style: TextStyle(
                              color:
                                  _statusMessage.contains('Error')
                                      ? Colors.red[700]
                                      : Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to AppState changes to update when a recipe is selected
    final appState = Provider.of<AppState>(context);
    if (appState.selectedRecipe != null &&
        (_currentRecipe == null ||
            _currentRecipe!.title != appState.selectedRecipe!.title)) {
      _currentRecipe = appState.selectedRecipe;
      // Scroll to the recipe card
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent *
                0.3, // Approximate position to scroll to the recipe
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
      // Optional: clear from app state after using it
      // appState.clearSelectedRecipe();
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: AppTheme.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('FlavorLens', style: AppTheme.headingLarge),
                        Text(
                          'Convert ingredients into recipes',
                          style: AppTheme.caption,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Input mode selection
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(
                      _inputModes.length,
                      (index) => Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_selectedInputMode != index) {
                              setState(() {
                                _selectedInputMode = index;
                                // Reset animation and play
                                _animationController.reset();
                                _animationController.forward();
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  _selectedInputMode == index
                                      ? AppTheme.primaryColor
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    index == 0
                                        ? Icons.image
                                        : Icons.text_fields,
                                    color:
                                        _selectedInputMode == index
                                            ? Colors.white
                                            : Colors.grey[600],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _inputModes[index],
                                    style: TextStyle(
                                      color:
                                          _selectedInputMode == index
                                              ? Colors.white
                                              : Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Filter section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recipe Preferences', style: AppTheme.headingSmall),
                      const SizedBox(height: 16),

                      // First row - Diet and Method
                      Row(
                        children: [
                          // Diet filter dropdown
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              decoration: AppTheme.inputDecoration(
                                'Dietary Filter',
                              ),
                              value: _selectedDiet,
                              items:
                                  _dietOptions
                                      .map(
                                        (diet) => DropdownMenuItem(
                                          value: diet,
                                          child: Text(diet),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedDiet = value!;
                                });
                              },
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Preparation method dropdown
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              decoration: AppTheme.inputDecoration(
                                'Preparation Method',
                              ),
                              value: _selectedPreparationMethod,
                              items:
                                  _preparationMethods
                                      .map(
                                        (method) => DropdownMenuItem(
                                          value: method,
                                          child: Text(method),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPreparationMethod = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Servings dropdown - centered with reduced width
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: DropdownButtonFormField<int>(
                            decoration: AppTheme.inputDecoration('Servings'),
                            value: _servings,
                            items:
                                _servingOptions
                                    .map(
                                      (servings) => DropdownMenuItem(
                                        value: servings,
                                        child: Text('$servings'),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                _servings = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Input section (varies based on selected mode)
                _buildInputSection(),

                const SizedBox(height: 24),

                // Generate button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading || _processingImage ? null : _generateRecipe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child:
                        _isLoading
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _generatingRecipe
                                      ? 'Generating Recipe...'
                                      : _generatingImage
                                      ? 'Creating Image...'
                                      : 'Processing...',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _selectedInputMode == 0 &&
                                          _imageFile != null &&
                                          _extractedIngredients.isEmpty
                                      ? Icons.document_scanner
                                      : Icons.restaurant_menu,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedInputMode == 0 &&
                                          _imageFile != null &&
                                          _extractedIngredients.isEmpty
                                      ? 'Scan Ingredients'
                                      : 'Generate Recipe',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),

                const SizedBox(height: 30),

                // Generated recipe
                if (_currentRecipe != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Generated Recipe',
                            style: AppTheme.headingMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      RecipeCard(recipe: _currentRecipe!),
                    ],
                  ),

                const SizedBox(height: 30),

                // Recent recipes section
                if (_recentRecipes.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Recent Recipes', style: AppTheme.headingMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentRecipes.length,
                      separatorBuilder:
                          (context, index) =>
                              Divider(color: Colors.grey[200], height: 1),
                      itemBuilder: (context, index) {
                        final recipe = _recentRecipes[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            recipe.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${recipe.ingredients.length} ingredients • ${recipe.steps.length} steps',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.restaurant_menu,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                          ),
                          onTap: () {
                            // Update both local state and AppState
                            setState(() {
                              _currentRecipe = recipe;
                            });
                            // Also update AppState so other screens know which recipe is selected
                            Provider.of<AppState>(
                              context,
                              listen: false,
                            ).setSelectedRecipe(recipe);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textInputController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
