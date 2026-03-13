import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe image - Adapts to image size with aspect ratio
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child:
                recipe.imageUrl.isNotEmpty
                    ? _buildRecipeImage(recipe.imageUrl)
                    : _buildPlaceholderImage(),
          ),

          // Recipe content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Preparation method and servings
                Row(
                  children: [
                    Chip(
                      label: Text(
                        'Method: ${recipe.preparationMethod}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      backgroundColor: Colors.deepOrange.shade300,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        'Serves: ${recipe.servings}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      backgroundColor: Colors.deepOrange.shade300,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Ingredients section
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 8),
                ...recipe.ingredients.map(
                  (ingredient) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            ingredient,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Steps section
                const Text(
                  'Instructions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  recipe.steps.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(
                            color: Colors.deepOrange,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            recipe.steps[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Nutrition information
                const Text(
                  'Nutrition Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(recipe.nutrition, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeImage(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      try {
        // Extract the base64 part from data URL
        final base64String = imageUrl.split(',')[1];
        final imageBytes = base64Decode(base64String);

        return _buildAdaptiveImage(imageProvider: MemoryImage(imageBytes));
      } catch (e) {
        print('Error decoding base64 image: $e');
        return _buildPlaceholderImage();
      }
    } else {
      // Regular URL image
      return _buildAdaptiveImage(imageProvider: NetworkImage(imageUrl));
    }
  }

  Widget _buildAdaptiveImage({required ImageProvider imageProvider}) {
    return AspectRatio(
      aspectRatio:
          16 / 9, // Standard aspect ratio, but image will fill within this
      child: Image(
        image: imageProvider,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame == null) {
            return Center(
              child: Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.deepOrange),
                ),
              ),
            );
          }
          return child;
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return _buildPlaceholderImage();
        },
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.deepOrange.withOpacity(0.8),
      child: const Icon(Icons.restaurant, size: 80, color: Colors.white),
    );
  }
}
