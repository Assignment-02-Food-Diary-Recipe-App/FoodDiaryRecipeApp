import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class RecipeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addRecipe(Recipe recipe) async {
    await _firestore.collection('recipes').doc(recipe.id).set(recipe.toMap());
  }

  // Future<List<Recipe>> getRecipes() async {
  //   final snapshot = await _firestore.collection('recipes').get();
  //   return snapshot.docs.map((doc) => Recipe.fromMap(doc.data())).toList();
  // }

  Future<List<Recipe>> getRecipes() async {
    final snapshot = await _firestore.collection('recipes').get();
    return snapshot.docs.map((doc) => Recipe.fromMap(doc.data(), doc.id)).toList();
  }


  Future<void> deleteRecipe(String id) async {
    await _firestore.collection('recipes').doc(id).delete();
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _firestore.collection('recipes').doc(recipe.id).update(recipe.toMap());
  }

  Future<void> toggleLike(String recipeId, String userId) async {
  if (recipeId.trim().isEmpty) {
    throw ArgumentError(recipeId.trim() + " " + userId);
  }

  final docRef = _firestore.collection('recipes').doc(recipeId);
  final snapshot = await docRef.get();

  List<String> likedBy = List<String>.from(snapshot['likedBy'] ?? []);

  if (likedBy.contains(userId)) {
    likedBy.remove(userId);
  } else {
    likedBy.add(userId);
  }

  await docRef.update({'likedBy': likedBy});
}


}
