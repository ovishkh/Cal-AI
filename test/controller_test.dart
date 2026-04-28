import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cal_ai/controllers/navigation_controller.dart';
import 'package:cal_ai/controllers/app_controller.dart';
import 'package:cal_ai/models/recipe.dart';

void main() {
  group('NavigationController Tests', () {
    late NavigationController navigationController;

    setUp(() {
      navigationController = NavigationController();
    });

    test('initial index should be 0', () {
      expect(navigationController.currentIndex.value, 0);
    });

    test('changeTab updates index', () {
      navigationController.changeTab(2);
      expect(navigationController.currentIndex.value, 2);
    });
  });

  group('AppController Tests', () {
    late AppController appController;

    setUp(() {
      appController = AppController();
    });

    test('initial selected recipe should be null', () {
      expect(appController.selectedRecipe, isNull);
    });

    test('setSelectedRecipe updates value', () {
      final recipe = Recipe(
        title: 'Test Recipe',
        ingredients: ['Ingredient 1'],
        steps: ['Step 1'],
        imageUrl: '',
        nutrition: 'Calories: 100',
      );
      
      appController.setSelectedRecipe(recipe);
      expect(appController.selectedRecipe?.title, 'Test Recipe');
    });
  });
}
