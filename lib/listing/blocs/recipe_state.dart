import 'package:equatable/equatable.dart';
import '../models/recipe_model.dart';

abstract class RecipeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeLoaded extends RecipeState {
  final List<Recipe> recipes;

  RecipeLoaded(this.recipes);

  @override
  List<Object?> get props => [recipes];
}

class RecipeAddSuccess extends RecipeState {}

class RecipeAddFailure extends RecipeState {
  final String error;

  RecipeAddFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class RecipeDeleteFailure extends RecipeState {
  final String error;

  RecipeDeleteFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class RecipeUpdateFailure extends RecipeState {
  final String error;

  RecipeUpdateFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class RecipeError extends RecipeState {
  final String error;

  RecipeError(this.error);

  @override
  List<Object?> get props => [error];
}
