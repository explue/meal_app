class MealRoom {
  final String roomId;
  final String roomName;
  final List<dynamic> masterRecommendPool;
  final List<dynamic> shoppingList;
  final Map<String, dynamic> weeklySchedule; // 🛠️ 컨트롤러의 규격과 변수명 일치 완료
  final List<dynamic> wishMenus;             // 🛠️ 컨트롤러의 규격과 변수명 일치 완료
  final String? sharedMemo;

  const MealRoom({
    required this.roomId,
    required this.roomName,
    required this.masterRecommendPool,
    required this.shoppingList,
    required this.weeklySchedule,
    required this.wishMenus,
    this.sharedMemo,
  });

  // 🎯 파이어베이스 데이터베이스 문서를 다트 데이터로 무결점 변환하는 빌더 엔진
  factory MealRoom.fromMap(Map<String, dynamic> map, String id) {
    return MealRoom(
      roomId: id,
      roomName: map['room_name'] ?? map['roomName'] ?? '행복한 식탁',
      masterRecommendPool: List<dynamic>.from(map['master_recommend_pool'] ?? map['masterRecommendPool'] ?? []),
      shoppingList: List<dynamic>.from(map['shopping_list'] ?? map['shoppingList'] ?? []),
      // 🛠️ 대소문자 및 구버전 데이터 필드 안전 결속(Fallback 처리)
      weeklySchedule: Map<String, dynamic>.from(map['weekly_schedule'] ?? map['weeklySchedule'] ?? {}),
      wishMenus: List<dynamic>.from(map['wish_menus'] ?? map['wishMenus'] ?? []),
      sharedMemo: map['shared_memo'] ?? map['sharedMemo'],
    );
  }

  // 🎯 다트 데이터를 파이어베이스 문서 포맷으로 변환하는 엔진
  Map<String, dynamic> toMap() {
    return {
      'room_name': roomName,
      'master_recommend_pool': masterRecommendPool,
      'shopping_list': shoppingList,
      'weekly_schedule': weeklySchedule,
      'wish_menus': wishMenus,
      'shared_memo': sharedMemo,
    };
  }
}