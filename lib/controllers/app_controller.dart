import 'package:get/get.dart';
import '../models/recipe.dart';

class AppController extends GetxController {
  final RxInt _recipeCount = 0.obs;
  final Rxn<Recipe> _selectedRecipe = Rxn<Recipe>();

  int get recipeCount => _recipeCount.value;
  Recipe? get selectedRecipe => _selectedRecipe.value;

  void incrementRecipeCount() {
    _recipeCount.value++;
  }

  void setSelectedRecipe(Recipe recipe) {
    _selectedRecipe.value = recipe;
  }

  void clearSelectedRecipe() {
    _selectedRecipe.value = null;
  }
}
