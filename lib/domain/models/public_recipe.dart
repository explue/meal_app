class PublicRecipe {
  final String name;
  final String category;
  final List<Map<String, String>> ingredients;

  PublicRecipe({
    required this.name,
    required this.category,
    required this.ingredients,
  });

  // 파이어베이스 글로벌 컬렉션 업로드를 위한 맵 변환기
  Map<String, dynamic> toMap() {
    return {
      'n': name,
      'cat': category,
      'ing': ingredients,
    };
  }

  // 글로벌 서버 데이터를 읽어오기 위한 팩토리 생성자
  factory PublicRecipe.fromMap(Map<String, dynamic> map) {
    return PublicRecipe(
      name: map['n'] ?? '',
      category: map['cat'] ?? '',
      ingredients: List<Map<String, dynamic>>.from(map['ing'] ?? [])
          .map((e) => {'name': e['name'].toString(), 'amount': e['amount'].toString()})
          .toList(),
    );
  }
}