# Cal AI API Documentation

## Overview

Cal AI uses the **Google Gemini API** for all AI-powered features including recipe generation, meal planning, and nutritional analysis.

## Gemini API Integration

### Base Information

- **API Provider**: Google
- **Model**: Gemini 1.5 Pro
- **Base URL**: `https://generativelanguage.googleapis.com`
- **Authentication**: API Key in Authorization header
- **Rate Limit**: Depends on your Google Cloud plan

### Getting Started with Gemini API

#### 1. Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable the "Generative Language API"

#### 2. Get Your API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Click "Create API Key"
3. Copy your API key

#### 3. Add API Key to Cal AI

Create a file at `lib/config/api_keys.dart`:

```dart
class ApiKeys {
  static const String geminiApiKey = 'YOUR_API_KEY_HERE';
}
```

> ⚠️ **IMPORTANT**: This file is in `.gitignore`. Never commit it to version control!

## API Endpoints Used

### 1. Recipe Generation

**Endpoint**: `POST /v1beta/models/gemini-pro:generateContent`

**Purpose**: Generate recipes based on ingredients or preferences

**Request Body**:

```json
{
  "contents": [
    {
      "parts": [
        {
          "text": "Generate a detailed recipe for [ingredients] with [dietary filter]. Include ingredients, steps, and estimated nutrition."
        }
      ]
    }
  ]
}
```

**Response**:

```json
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "Recipe details..."
          }
        ]
      }
    }
  ]
}
```

**Implementation in Cal AI**:

```dart
// File: lib/services/gemini_api.dart
Future<Recipe> generateRecipe(String ingredients, String dietaryFilter) async {
  final prompt = '''
    Generate a detailed recipe for the following ingredients: $ingredients
    Dietary preference: $dietaryFilter

    Format the response as JSON with:
    - title: string
    - ingredients: array of strings
    - steps: array of strings
    - nutrition: object with calories, protein, carbs, fat
    - cookTime: string
  ''';

  final response = await http.post(
    Uri.parse('$baseUrl/v1beta/models/gemini-pro:generateContent?key=$apiKey'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'contents': [{'parts': [{'text': prompt}]}]}),
  );

  // Parse and return Recipe object
}
```

### 2. Meal Planning

**Purpose**: Generate personalized weekly meal plans

**Implementation**:

```dart
Future<MealPlan> generateMealPlan(List<String> preferences) async {
  final prompt = '''
    Create a 7-day meal plan with these preferences: ${preferences.join(', ')}

    Format as JSON with:
    - Monday to Sunday: array of recipes
    - shoppingList: array of items
    - totalCalories: number
  ''';

  // Similar API call structure
}
```

### 3. Nutritional Analysis

**Purpose**: Analyze and provide nutritional information for recipes

**Implementation**:

```dart
Future<NutritionInfo> analyzeNutrition(String recipeTitle) async {
  final prompt = '''
    Analyze the nutritional content of: $recipeTitle

    Provide:
    - calories
    - protein (grams)
    - carbohydrates (grams)
    - fat (grams)
    - fiber (grams)
    - vitamins and minerals
  ''';

  // Similar API call structure
}
```

### 4. Image Analysis

**Purpose**: Analyze ingredient images to suggest recipes

**Implementation**:

```dart
Future<Recipe> analyzeIngredientImage(List<int> imageBytes) async {
  // Convert image to base64
  final base64Image = base64Encode(imageBytes);

  final response = await http.post(
    Uri.parse('$baseUrl/v1beta/models/gemini-pro-vision:generateContent?key=$apiKey'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': 'Identify the ingredients in this image and suggest recipes'},
            {'inlineData': {'data': base64Image, 'mimeType': 'image/jpeg'}}
          ]
        }
      ]
    }),
  );

  // Parse response and generate recipe
}
```

## Request/Response Format

### Standard Request Format

```dart
https://generativelanguage.googleapis.com/v1beta/models/{model-name}:generateContent?key={API_KEY}

Headers:
- Content-Type: application/json

Body:
{
  "contents": [
    {
      "parts": [
        {"text": "Your prompt here"},
        // Optional: image data for vision models
      ]
    }
  ],
  "generationConfig": {
    "temperature": 0.7,
    "topK": 40,
    "topP": 0.95,
    "maxOutputTokens": 2048
  }
}
```

### Generation Configuration

| Parameter         | Default | Range     | Description                         |
| ----------------- | ------- | --------- | ----------------------------------- |
| `temperature`     | 0.7     | 0.0 - 2.0 | Randomness of responses             |
| `topK`            | 40      | 1 - 40    | Number of token options to consider |
| `topP`            | 0.95    | 0.0 - 1.0 | Nucleus sampling parameter          |
| `maxOutputTokens` | -       | 1 - 2048  | Maximum response length             |

### Error Handling

```dart
try {
  final recipe = await geminiApiService.generateRecipe(ingredients);
} catch (e) {
  if (e.toString().contains('401')) {
    // Invalid API key
    print('Invalid API key');
  } else if (e.toString().contains('429')) {
    // Rate limit exceeded
    print('Too many requests. Try again later.');
  } else if (e.toString().contains('500')) {
    // Server error
    print('API service error. Try again later.');
  } else {
    print('Unexpected error: $e');
  }
}
```

## Configuration

### Change API Endpoint

Edit `lib/services/gemini_api.dart`:

```dart
class GeminiApiService {
  static const String baseUrl = 'https://generativelanguage.googleapis.com';
  static const String modelName = 'gemini-pro'; // or 'gemini-pro-vision'

  // Change these for different API versions
  static const String apiVersion = 'v1beta'; // Change to v1 for stable
}
```

### Change Model

Available models:

- `gemini-pro`: Text-based model
- `gemini-pro-vision`: Multimodal (text + images)
- `gemini-1.5-pro`: Newer, more powerful model (if available)

```dart
static const String modelName = 'gemini-pro-vision'; // For image analysis
```

### Change Generation Parameters

Edit `lib/services/gemini_api.dart`:

```dart
Map<String, dynamic> generationConfig = {
  'temperature': 0.7, // Lower = more deterministic, Higher = more creative
  'topK': 40,
  'topP': 0.95,
  'maxOutputTokens': 2048, // Increase for longer responses
};
```

## Pricing & Quotas

- **Free Tier**: Limited requests per day
- **Paid Tier**: Pay-per-request pricing
- **Rate Limits**: Check [Google AI Pricing](https://ai.google.dev/pricing)

## Best Practices

1. **Prompt Engineering**: Write clear, detailed prompts for better results
2. **Error Handling**: Always handle API errors gracefully
3. **Caching**: Cache responses to reduce API calls
4. **Rate Limiting**: Implement delays between requests
5. **Security**:
   - Store API key securely
   - Never expose key in client-side code in production
   - Use backend proxy for sensitive operations

## Troubleshooting

### Issue: 401 Unauthorized

- **Cause**: Invalid or missing API key
- **Solution**: Check API key in `lib/config/api_keys.dart`

### Issue: 429 Too Many Requests

- **Cause**: Rate limit exceeded
- **Solution**: Implement request throttling and caching

### Issue: 500 Internal Server Error

- **Cause**: API service issue
- **Solution**: Retry after a delay, check API status

### Issue: Empty or Invalid Response

- **Cause**: Poor prompt or model limitation
- **Solution**: Refine your prompt, increase `maxOutputTokens`

### Issue: Image Analysis Not Working

- **Cause**: Using wrong model or invalid image format
- **Solution**: Use `gemini-pro-vision`, ensure image is valid JPEG/PNG

## Testing the API

### Manual Testing with cURL

```bash
curl -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{"text": "Write a recipe for pasta"}]
    }]
  }'
```

### Testing in Cal AI

```dart
void testGeminiApi() async {
  final service = GeminiApiService();
  try {
    final recipe = await service.generateRecipe('tomato, pasta, garlic', 'None');
    print('Success: ${recipe.title}');
  } catch (e) {
    print('Error: $e');
  }
}
```

## API Documentation Links

- [Google Generative AI Docs](https://ai.google.dev/docs)
- [Gemini API Reference](https://ai.google.dev/tutorials)
- [Google AI Studio](https://makersuite.google.com/)
- [Rate Limits and Quotas](https://ai.google.dev/docs/quota)

## Related Documentation

- [GETTING_STARTED.md](GETTING_STARTED.md): Setup instructions
- [CONFIGURATION.md](CONFIGURATION.md): Configuration guide
- [DEPENDENCIES.md](DEPENDENCIES.md): Package information
