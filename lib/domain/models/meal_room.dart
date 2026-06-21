class MealRoom {
  final String roomId;
  final List<Map<String, dynamic>> menuDatabase;
  final List<Map<String, dynamic>> shoppingList;
  final int servingCount;
  final Map<String, String> ingredientChecklist;
  final List<dynamic> masterRecommendPool; // RecipePool 객체 생성을 위한 원천 풀 데이터
  final String sharedMemo;
  final bool isShoppingStarted;
  
  // 🛠️ 대책: 화면에서 애타게 찾고 있는 위시 메뉴 리스트 필드 정밀 추가
  final List<dynamic>? wishMenuList; 

  const MealRoom({
    required this.roomId,
    required this.menuDatabase,
    required this.shoppingList,
    required this.servingCount,
    required this.ingredientChecklist,
    required this.masterRecommendPool,
    required this.sharedMemo,
    required this.isShoppingStarted,
    this.wishMenuList,
  });

  factory MealRoom.fromMap(String id, Map<String, dynamic> map) {
    return MealRoom(
      roomId: id,
      menuDatabase: List<Map<String, dynamic>>.from(map['menu_database'] ?? []),
      shoppingList: List<Map<String, dynamic>>.from(map['shopping_list'] ?? []),
      servingCount: map['serving_count'] ?? 2,
      ingredientChecklist: Map<String, String>.from(map['ingredient_checklist'] ?? {}),
      masterRecommendPool: List<dynamic>.from(map['master_recommend_pool'] ?? []),
      sharedMemo: map['shared_memo'] ?? '',
      isShoppingStarted: map['is_shopping_started'] ?? false,
      wishMenuList: map['wish_menu_list'] ?? [], // 🛠️ 매핑 바인딩 완공
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menu_database': menuDatabase,
      'shopping_list': shoppingList,
      'serving_count': servingCount,
      'ingredient_checklist': ingredientChecklist,
      'master_recommend_pool': masterRecommendPool,
      'shared_memo': sharedMemo,
      'is_shopping_started': isShoppingStarted,
      'wish_menu_list': wishMenuList,
    };
  }
}