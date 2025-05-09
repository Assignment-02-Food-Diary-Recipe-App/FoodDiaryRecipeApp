import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/recipe_bloc.dart';
import '../blocs/recipe_event.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  void _addComment() {
    final comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      final updatedRecipe = widget.recipe.copyWith(
        comments: [...widget.recipe.comments, comment],
      );

      context.read<RecipeBloc>().add(UpdateRecipeEvent(updatedRecipe));
      _commentController.clear();

      setState(() {
        widget.recipe.comments.add(comment);
      });
    }
  }

  void _deleteComment(int index) {
    final updatedComments = List<String>.from(widget.recipe.comments)
      ..removeAt(index);
    final updatedRecipe = widget.recipe.copyWith(comments: updatedComments);

    context.read<RecipeBloc>().add(UpdateRecipeEvent(updatedRecipe));

    setState(() {
      widget.recipe.comments.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment deleted')),
    );
  }

  bool isAdmin(User? user) {
    const adminUIDs = ['BTdIXsTbaMhbu9CPtKZbPiNhl7z2']; // TODO: Replace with your actual admin UID(s)
    return user != null && adminUIDs.contains(user.uid);
  }

  @override
Widget build(BuildContext context) {
  final recipe = widget.recipe;
  final currentUser = FirebaseAuth.instance.currentUser;

  return Scaffold(
    appBar: AppBar(
      title: Text(recipe.title),
      backgroundColor: Colors.deepOrange,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image or Placeholder
          const SizedBox(height: 20),

          // Recipe Info
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category: ${recipe.category}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text(recipe.description,
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 16),
                  const Text('Ingredients:',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...recipe.ingredients
                      .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.check, size: 18, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(child: Text(e)),
                              ],
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),

          // Comments Section
          const Text('Comments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (recipe.comments.isEmpty)
            const Text('No comments yet. Be the first!',
                style: TextStyle(color: Colors.grey)),
          ...recipe.comments.asMap().entries.map((entry) {
            final index = entry.key;
            final comment = entry.value;
            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.comment, color: Colors.deepOrange),
                title: Text(comment),
                trailing: isAdmin(currentUser)
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteComment(index),
                      )
                    : null,
              ),
            );
          }),

          const SizedBox(height: 20),

          // Comment Input
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Add a comment...',
              filled: true,
              fillColor: Colors.orange.shade50,
              prefixIcon: const Icon(Icons.chat_bubble_outline),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: Colors.deepOrange),
                onPressed: _addComment,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}