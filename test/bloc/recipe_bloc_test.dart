// test/blocs/recipe_bloc_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:food_recipe_app/listing/blocs/recipe_bloc.dart';
import 'package:food_recipe_app/listing/blocs/recipe_event.dart';
import 'package:food_recipe_app/listing/blocs/recipe_state.dart';
import 'package:food_recipe_app/listing/models/recipe_model.dart';
import 'package:food_recipe_app/listing/repository/recipe_repository.dart';

import '../mocks/mock_recipe_repository.mocks.dart';

void main() {
  late MockRecipeRepository mockRecipeRepository;
  late RecipeBloc recipeBloc;

  final dummyRecipe = Recipe(
    id: '1',
    title: 'Test Recipe',
    description: 'Test Desc',
    ingredients: ['Eggs', 'Milk'],
    category: 'Desi',
    creatorId: 'tZx3iZTnyjcweLwWVhJnhOkKo462',
    likedBy: [],
  );

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
    recipeBloc = RecipeBloc(repository: mockRecipeRepository);
  });

  tearDown(() => recipeBloc.close());

  group('RecipeBloc Tests', () {
    blocTest<RecipeBloc, RecipeState>(
      'emits [RecipeLoading, RecipeLoaded] when FetchRecipesEvent is added and succeeds',
      build: () {
        when(mockRecipeRepository.getRecipes()).thenAnswer((_) async => [dummyRecipe]);
        return recipeBloc;
      },
      act: (bloc) => bloc.add(FetchRecipesEvent()),
      expect: () => [
        RecipeLoading(),
        isA<RecipeLoaded>().having((s) => s.recipes.length, 'recipes length', 1),
      ],
    );

    blocTest<RecipeBloc, RecipeState>(
      'emits [RecipeAddFailure] when FetchRecipesEvent fails',
      build: () {
        when(mockRecipeRepository.getRecipes()).thenThrow(Exception('Fetch error'));
        return recipeBloc;
      },
      act: (bloc) => bloc.add(FetchRecipesEvent()),
      expect: () => [
        RecipeLoading(),
        isA<RecipeAddFailure>().having((e) => e.error, 'error', contains('Fetch error')),
      ],
    );

    blocTest<RecipeBloc, RecipeState>(
      'emits [RecipeLoaded] after successful AddRecipeEvent',
      build: () {
        when(mockRecipeRepository.addRecipe(any)).thenAnswer((_) async => {});
        when(mockRecipeRepository.getRecipes()).thenAnswer((_) async => [dummyRecipe]);
        return recipeBloc;
      },
      act: (bloc) => bloc.add(AddRecipeEvent(dummyRecipe)),
      expect: () => [isA<RecipeLoaded>()],
    );

    blocTest<RecipeBloc, RecipeState>(
      'emits [RecipeAddFailure] when AddRecipeEvent fails',
      build: () {
        when(mockRecipeRepository.addRecipe(any)).thenThrow(Exception('Add error'));
        return recipeBloc;
      },
      act: (bloc) => bloc.add(AddRecipeEvent(dummyRecipe)),
      expect: () => [
        isA<RecipeAddFailure>().having((e) => e.error, 'error', contains('Add error')),
      ],
    );

    blocTest<RecipeBloc, RecipeState>(
      'emits [RecipeError] when ToggleLikeRecipeEvent fails',
      build: () {
        when(mockRecipeRepository.toggleLike(any, any)).thenThrow(Exception('Toggle error'));
        return recipeBloc;
      },
      act: (bloc) => bloc.add(ToggleLikeRecipeEvent(recipeId: '1', userId: 'u1')),
      expect: () => [
        isA<RecipeError>().having((e) => e.error, 'error', contains('Toggle error')),
      ],
    );

    blocTest<RecipeBloc, RecipeState>(
      'calls getRecipes after DeleteRecipeEvent',
      build: () {
        when(mockRecipeRepository.deleteRecipe(any)).thenAnswer((_) async => {});
        when(mockRecipeRepository.getRecipes()).thenAnswer((_) async => [dummyRecipe]);
        return recipeBloc;
      },
      act: (bloc) => bloc.add(DeleteRecipeEvent('1')),
      verify: (_) {
        verify(mockRecipeRepository.deleteRecipe('1')).called(1);
        verify(mockRecipeRepository.getRecipes()).called(1);
      },
    );

    blocTest<RecipeBloc, RecipeState>(
      'emits [RecipeDeleteFailure] when DeleteRecipeEvent fails',
      build: () {
        when(mockRecipeRepository.deleteRecipe(any)).thenThrow(Exception('Delete error'));
        return recipeBloc;
      },
      act: (bloc) => bloc.add(DeleteRecipeEvent('1')),
      expect: () => [
        isA<RecipeDeleteFailure>().having((e) => e.error, 'error', contains('Delete error')),
      ],
    );
  });
}
