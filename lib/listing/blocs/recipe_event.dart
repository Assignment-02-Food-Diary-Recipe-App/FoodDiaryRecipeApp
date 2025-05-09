import 'package:food_recipe_app/listing/models/recipe_model.dart';

abstract class RecipeEvent {}

class FetchRecipesEvent extends RecipeEvent {}

class AddRecipeEvent extends RecipeEvent {
  final Recipe recipe;
  AddRecipeEvent(this.recipe);
}

class DeleteRecipeEvent extends RecipeEvent {
  final String recipeId;
  DeleteRecipeEvent(this.recipeId);
}

class UpdateRecipeEvent extends RecipeEvent {
  final Recipe recipe;
  UpdateRecipeEvent(this.recipe);
}

class ToggleLikeRecipeEvent extends RecipeEvent {
  final String recipeId;
  final String userId;

  ToggleLikeRecipeEvent({required this.recipeId, required this.userId});
}