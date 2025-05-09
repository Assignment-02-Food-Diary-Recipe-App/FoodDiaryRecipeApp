import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/recipe_repository.dart';
import '../models/recipe_model.dart';
import 'recipe_event.dart';
import 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final RecipeRepository repository;

  RecipeBloc({required this.repository}) : super(RecipeInitial()) {
    on<FetchRecipesEvent>((event, emit) async {
      emit(RecipeLoading());
      try {
        final recipes = await repository.getRecipes();
        emit(RecipeLoaded(recipes));
      } catch (e) {
        emit(RecipeAddFailure(e.toString()));
      }
    });

    on<AddRecipeEvent>((event, emit) async {
      try {
        await repository.addRecipe(event.recipe);
        final recipes = await repository.getRecipes();
        emit(RecipeLoaded(recipes));
      } catch (e) {
        emit(RecipeAddFailure(e.toString()));
      }
    });

    
    on<DeleteRecipeEvent>(_onDeleteRecipe);
    
    on<UpdateRecipeEvent>(_onUpdateRecipe);

    on<ToggleLikeRecipeEvent>((event, emit) async {
      try {
        await repository.toggleLike(event.recipeId, event.userId);
        add(FetchRecipesEvent()); // Refresh
      } catch (e) {
        emit(RecipeError('Failed to toggle like: $e'));
      }
    });

  }

  Future<void> _onDeleteRecipe(DeleteRecipeEvent event, Emitter<RecipeState> emit) async {
    try {
      await repository.deleteRecipe(event.recipeId);
      add(FetchRecipesEvent());
    } catch (e) {
      emit(RecipeDeleteFailure(e.toString()));
    }
  }

  Future<void> _onUpdateRecipe(UpdateRecipeEvent event, Emitter<RecipeState> emit) async {
    try {
      await repository.updateRecipe(event.recipe);
      add(FetchRecipesEvent());
    } catch (e) {
      emit(RecipeUpdateFailure(e.toString()));
    }
  }

  
}
