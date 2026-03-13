class NutritionInfo {
  final String foodName;
  final int calories;
  final NutritionMacros macros;
  final int healthScore;
  final String description;
  final List<String> nutritionTips;

  NutritionInfo({
    required this.foodName,
    required this.calories,
    required this.macros,
    required this.healthScore,
    required this.description,
    required this.nutritionTips,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      foodName: json['foodName'] ?? 'Unknown Food',
      calories: json['calories'] ?? 0,
      macros: NutritionMacros.fromJson(json['macros'] ?? {}),
      healthScore: json['healthScore'] ?? 0,
      description: json['description'] ?? '',
      nutritionTips: List<String>.from(json['nutritionTips'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodName': foodName,
      'calories': calories,
      'macros': macros.toJson(),
      'healthScore': healthScore,
      'description': description,
      'nutritionTips': nutritionTips,
    };
  }
}

class NutritionMacros {
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  NutritionMacros({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  factory NutritionMacros.fromJson(Map<String, dynamic> json) {
    return NutritionMacros(
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      fiber: (json['fiber'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'protein': protein, 'carbs': carbs, 'fat': fat, 'fiber': fiber};
  }
}
