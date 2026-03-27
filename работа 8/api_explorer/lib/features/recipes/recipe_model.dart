class Recipe {
  final String title;
  final String ingredients;
  final String servings;
  final String instructions;

  Recipe({
    required this.title,
    required this.ingredients,
    required this.servings,
    required this.instructions,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'] ?? 'Unknown',
      ingredients: json['ingredients'] ?? '',
      servings: json['servings'] ?? '',
      instructions: json['instructions'] ?? '',
    );
  }
}
