import 'dart:async';
import 'dart:typed_data';
import 'dart:io' as io show File;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../blocs/recipe_bloc.dart';
import '../blocs/recipe_event.dart';
import '../models/recipe_model.dart';

class AddOrEditRecipeScreen extends StatefulWidget {
  final Recipe? existingRecipe;

  const AddOrEditRecipeScreen({super.key, this.existingRecipe});

  @override
  State<AddOrEditRecipeScreen> createState() => _AddOrEditRecipeScreenState();
}

class _AddOrEditRecipeScreenState extends State<AddOrEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _ingredientsController;
  late TextEditingController _categoryController;

  Uint8List? _webImageBytes;
  io.File? _pickedImageFile;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingRecipe?.title ?? '');
    _descController = TextEditingController(text: widget.existingRecipe?.description ?? '');
    _ingredientsController = TextEditingController(
      text: widget.existingRecipe?.ingredients.join(', ') ?? '',
    );
    _categoryController = TextEditingController(text: widget.existingRecipe?.category ?? '');
    // _uploadedImageUrl = widget.existingRecipe?.imageUrl;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _pickedImageFile = null;
        });
      } else {
        setState(() {
          _pickedImageFile = io.File(pickedFile.path);
          _webImageBytes = null;
        });
      }
    }
  }

  Future<String?> _uploadImage() async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('recipe_images')
          .child('${const Uuid().v4()}.jpg');

      UploadTask uploadTask;

      if (kIsWeb && _webImageBytes != null) {
        print('🌐 Uploading web image...');
        final metadata = SettableMetadata(contentType: 'image/jpeg');
        uploadTask = ref.putData(_webImageBytes!, metadata);
      } else if (_pickedImageFile != null) {
        print('📱 Uploading mobile image...');
        uploadTask = ref.putFile(_pickedImageFile!);
      } else {
        print('⚠️ No new image selected. Using existing one.');
        return _uploadedImageUrl;
      }

      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          print('📶 Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
        },
        onError: (e) {
          print('❌ Upload error: $e');
        },
      );

      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException("Upload timed out");
        },
      );

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print('✅ Image uploaded: $downloadUrl');
        return downloadUrl;
      } else {
        print('❌ Upload failed with state: ${snapshot.state}');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ Exception during upload: $e');
      print(stackTrace);
      return null;
    }
  }

  Future<void> _submitRecipe() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (!_formKey.currentState!.validate()) return;

    // final imageUrl = await _uploadImage();

    // if (imageUrl == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Image upload failed. Please try again.')),
    //   );
    //   return;
    // }

    final ingredientsList = _ingredientsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final recipe = Recipe(
      id: widget.existingRecipe?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      ingredients: ingredientsList,
      category: _categoryController.text.trim(),
      // imageUrl: imageUrl,
      creatorId: user.uid,
    );

    if (widget.existingRecipe == null) {
      context.read<RecipeBloc>().add(AddRecipeEvent(recipe));
    } else {
      context.read<RecipeBloc>().add(UpdateRecipeEvent(recipe));
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.existingRecipe == null ? 'Recipe added!' : 'Recipe updated!')),
    );
  }

  Widget _buildImagePreview() {
    if (_webImageBytes != null) {
      return Image.memory(_webImageBytes!, height: 200, fit: BoxFit.cover);
    } else if (_pickedImageFile != null) {
      return Image.file(_pickedImageFile!, height: 200, fit: BoxFit.cover);
    } else if (_uploadedImageUrl != null) {
      return Image.network(_uploadedImageUrl!, height: 200, fit: BoxFit.cover);
    } else {
      return const Text('No image selected.');
    }
  }

@override
Widget build(BuildContext context) {
  final isEdit = widget.existingRecipe != null;

  return Scaffold(
    appBar: AppBar(
      title: Text(isEdit ? 'Edit Recipe' : 'Add Recipe'),
      backgroundColor: Colors.deepOrange,
      centerTitle: true,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'Recipe Image',
            //   style: Theme.of(context).textTheme.titleLarge,
            // ),
            // const SizedBox(height: 8),
            // GestureDetector(
            //   onTap: _pickImage,
            //   child: _buildImagePreview(),
            // ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter title' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter description' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ingredientsController,
                      decoration: InputDecoration(
                        labelText: 'Ingredients',
                        hintText: 'e.g. rice, chicken, spices',
                        prefixIcon: Icon(Icons.kitchen),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter ingredients' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter category' : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: _submitRecipe,
                icon: Icon(isEdit ? Icons.edit : Icons.add, color: Colors.black,),
                label: Text(
                  isEdit ? 'Update Recipe' : 'Add Recipe',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}