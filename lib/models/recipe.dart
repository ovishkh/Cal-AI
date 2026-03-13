class Recipe {
  final String title;
  final List<String> ingredients;
  final List<String> steps;
  final String imageUrl;
  final String nutrition;
  final String preparationMethod;
  final int servings;

  Recipe({
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.nutrition,
    this.preparationMethod = 'Any Method',
    this.servings = 2,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'],
      ingredients: List<String>.from(json['ingredients']),
      steps: List<String>.from(json['steps']),
      imageUrl: json['imageUrl'],
      nutrition: json['nutrition'],
      preparationMethod: json['preparationMethod'] ?? 'Any Method',
      servings: json['servings'] ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'ingredients': ingredients,
      'steps': steps,
      'imageUrl': imageUrl,
      'nutrition': nutrition,
      'preparationMethod': preparationMethod,
      'servings': servings,
    };
  }
}
