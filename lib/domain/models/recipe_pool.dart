import 'ingredient.dart';

class RecipePool {
  final String name;
  final String category;
  final List<Ingredient> ingredients;

  const RecipePool({
    required this.name,
    required this.category,
    required this.ingredients,
  });

  factory RecipePool.fromMap(Map<String, dynamic> map) {
    final rawIng = map['ing'] as List<dynamic>? ?? [];
    final dishName = map['n'] ?? '';
    final cat = map['cat'] ?? '';

    return RecipePool(
      name: dishName,
      category: cat,
      ingredients: rawIng.map((e) => Ingredient.fromMap(Map<String, dynamic>.from(e), defaultId: '${dishName}_${e['name']}')).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'n': name,
      'cat': category,
      'ing': ingredients.map((e) => {'name': e.name, 'amount': e.amount}).toList(),
    };
  }
}