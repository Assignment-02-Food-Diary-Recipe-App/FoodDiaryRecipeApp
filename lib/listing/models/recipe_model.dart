class Recipe {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final String category;
  final List<String> likedBy;
  // final String? imageUrl;
  final List<String> comments;
  final String creatorId;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.category,
    this.likedBy = const [],
    // this.imageUrl,
    this.comments = const [],
    required this.creatorId,
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? ingredients,
    String? category,
    List<String>? likedBy,
    // String? imageUrl,
    List<String>? comments,
    String? creatorId
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      category: category ?? this.category,
      likedBy: likedBy ?? this.likedBy,
      // imageUrl: imageUrl ?? this.imageUrl,
      comments: comments ?? this.comments,
      creatorId: creatorId ?? this.creatorId
    );
  }

  factory Recipe.fromMap(Map<String, dynamic> map, String id) {
    return Recipe(
      id: id,
      title: map['title'],
      description: map['description'],
      ingredients: List<String>.from(map['ingredients'] ?? []),
      category: map['category'],
      likedBy: List<String>.from(map['likedBy'] ?? []),
      // imageUrl: map['imageUrl'],
      comments: List<String>.from(map['comments'] ?? []),
      creatorId: map['creatorId']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'category': category,
      'likedBy': likedBy,
      // 'imageUrl': imageUrl,
      'comments': comments,
      'creatorId' : creatorId
    };
  }
}
