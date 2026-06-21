class Ingredient {
  final String id;
  final String name;
  final String amount;
  final String parentMenu;
  final bool isManual;

  const Ingredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.parentMenu,
    this.isManual = false,
  });

  factory Ingredient.fromMap(Map<String, dynamic> map, {String? defaultId}) {
    return Ingredient(
      id: map['id'] ?? defaultId ?? '',
      name: map['name'] ?? '',
      amount: map['amount']?.toString() ?? '',
      parentMenu: map['parent_menu'] ?? '',
      isManual: map['is_manual'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'parent_menu': parentMenu,
      'is_manual': isManual,
    };
  }
}