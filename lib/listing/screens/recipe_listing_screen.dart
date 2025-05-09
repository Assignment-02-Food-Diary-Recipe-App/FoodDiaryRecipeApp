// lib/listing/screens/recipe_listing_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/listing/screens/add_recipe_screen.dart';
import 'package:food_recipe_app/listing/screens/recipe_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/recipe_bloc.dart';
import '../blocs/recipe_event.dart';
import '../blocs/recipe_state.dart';
import '../models/recipe_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeListingScreen extends StatefulWidget {
  const RecipeListingScreen({super.key});

  @override
  State<RecipeListingScreen> createState() => _RecipeListingScreenState();
}

class _RecipeListingScreenState extends State<RecipeListingScreen> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<RecipeBloc>().add(FetchRecipesEvent());

    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  void _deleteRecipe(String id) {
    context.read<RecipeBloc>().add(DeleteRecipeEvent(id));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Recipe deleted')));
  }

  List<Recipe> _filterRecipes(List<Recipe> recipes) {
    if (searchQuery.isEmpty) return recipes;

    return recipes.where((r) {
      return r.title.toLowerCase().contains(searchQuery) ||
          r.category.toLowerCase().contains(searchQuery);
    }).toList();
  }

  bool isAdmin(User? user) {
    const adminUIDs = [
      'BTdIXsTbaMhbu9CPtKZbPiNhl7z2',
    ]; // Replace with real UID(s)
    return user != null && adminUIDs.contains(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid ?? '';
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddOrEditRecipeScreen(),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title or category...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<RecipeBloc, RecipeState>(
        builder: (context, state) {
          if (state is RecipeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RecipeLoaded) {
            final filteredRecipes = _filterRecipes(state.recipes);

            if (filteredRecipes.isEmpty) {
              return const Center(child: Text('No matching recipes found.'));
            }

            final grouped = <String, List<Recipe>>{};
            for (var recipe in filteredRecipes) {
              grouped.putIfAbsent(recipe.category, () => []).add(recipe);
            }

            return ListView(
              padding: const EdgeInsets.all(12),
              children:
                  grouped.entries.map((entry) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          collapsedIconColor: Colors.deepOrange,
                          iconColor: Colors.deepOrange,
                          title: Text(
                            entry.key,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                          children:
                              entry.value.map((recipe) {
                                final user = FirebaseAuth.instance.currentUser;
                                final bool canDelete =
                                    recipe.creatorId == user?.uid ||
                                    isAdmin(user);

                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => RecipeDetailScreen(
                                              recipe: recipe,
                                            ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDFDFD),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.orange.shade100,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recipe.title,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          recipe.description,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Ingredients: ${recipe.ingredients.join(', ')}',
                                          style: GoogleFonts.poppins(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            if (recipe.creatorId == user?.uid ||
                                                isAdmin(user))
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blueAccent,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (_) =>
                                                              AddOrEditRecipeScreen(
                                                                existingRecipe:
                                                                    recipe,
                                                              ),
                                                    ),
                                                  );
                                                },
                                              ),

                                            if (canDelete)
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.redAccent,
                                                ),
                                                onPressed:
                                                    () => _deleteRecipe(
                                                      recipe.id,
                                                    ),
                                              ),
                                            IconButton(
                                              icon: Icon(
                                                recipe.likedBy.contains(
                                                      currentUserId,
                                                    )
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: Colors.redAccent,
                                              ),
                                              onPressed: () {
                                                if (recipe.id
                                                    .trim()
                                                    .isNotEmpty) {
                                                  context
                                                      .read<RecipeBloc>()
                                                      .add(
                                                        ToggleLikeRecipeEvent(
                                                          recipeId: recipe.id,
                                                          userId: currentUserId,
                                                        ),
                                                      );
                                                }
                                              },
                                            ),
                                            Text(
                                              '${recipe.likedBy.length}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    );
                  }).toList(),
            );
          } else if (state is RecipeError) {
            return Center(child: Text('Error: ${state.error}'));
          }

          return const Center(child: Text('No recipes found.'));
        },
      ),
    );
  }
}
