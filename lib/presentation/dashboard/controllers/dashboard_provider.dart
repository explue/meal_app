import 'dart:math'; // 🎯 난수 생성을 위해 추가
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/models/meal_room.dart';
import '../../../domain/models/recipe_pool.dart';

final currentRoomIdProvider = StateProvider<String>((ref) => ""); // 초기값 빈 문자열로 정정
final currentLanguageProvider = StateProvider<String>((ref) => "ko");
final roomRepositoryProvider = Provider((ref) => Object());
final currentUserNicknameProvider = StateProvider<String>((ref) => ""); // StateProvider로 변경하여 닉네임 변경 반영

final mealRoomStreamProvider = StreamProvider.family<MealRoom, String>((ref, roomId) {
  return FirebaseFirestore.instance
      .collection('meal_rooms')
      .doc(roomId)
      .snapshots()
      .map((snapshot) => MealRoom.fromMap(snapshot.data() ?? {}, roomId));
});

final dashboardControllerProvider = Provider<DashboardController>((ref) {
  return DashboardController(ref);
});

class DashboardController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Ref ref;

  DashboardController(this.ref);

  // 🎯 6자리 난수 방 번호 생성 함수
  String _generateRoomCode() {
    final random = Random();
    return List.generate(6, (index) => random.nextInt(10)).join();
  }

  // 🎯 방 번호를 직접 지정(ID)하여 생성하는 로직으로 강화
  Future<String> createNewRoom(String name) async {
    String roomCode = _generateRoomCode();
    
    // 중복 방지: 이미 존재하는 번호인지 확인 후 생성
    var docSnapshot = await _db.collection('meal_rooms').doc(roomCode).get();
    while (docSnapshot.exists) {
      roomCode = _generateRoomCode();
      docSnapshot = await _db.collection('meal_rooms').doc(roomCode).get();
    }

    final docRef = _db.collection('meal_rooms').doc(roomCode);
    await docRef.set({
      'room_name': name,
      'master_recommend_pool': [],
      'shopping_list': [],
      'weekly_schedule': {},
      'wish_menus': [],
      'shared_memo': '',
      'created_at': FieldValue.serverTimestamp(), // 생성 시간 추가
    });
    
    // 현재 방 ID를 전역 상태로 저장
    ref.read(currentRoomIdProvider.notifier).state = roomCode;
    return roomCode;
  }

  Future<bool> verifyRoomExists(String roomId) async {
    if (roomId.isEmpty) return false;
    final doc = await _db.collection('meal_rooms').doc(roomId).get();
    return doc.exists;
  }

  Future<void> saveRoomSession(String roomId) async {}
  Future<void> initAppSession() async {}
  
  Future<void> saveUserNickname(String nickname) async {}
  Future<void> leaveRoom(String roomId) async {}
  Future<void> changeLanguage(String langCode) async {}

  // 위시보드 신규 메뉴 추가 함수 복원
  Future<void> addWishMenu(MealRoom room, String menuName, String user) async {
    final roomRef = _db.collection('meal_rooms').doc(room.roomId);
    List<dynamic> currentWishes = List.from(room.wishMenus ?? []);
    currentWishes.add({
      'menu_name': menuName,
      'user_name': user,
      'created_at': DateTime.now().toIso8601String(),
    });
    await roomRef.update({'wish_menus': currentWishes});
  }

  // [요리방 비즈니스 로직]
  Future<void> updateOrAddRecipe(MealRoom room, RecipePool recipe) async {
    final roomRef = _db.collection('meal_rooms').doc(room.roomId);
    final Map<String, dynamic> newRecipeMap = {
      'n': recipe.name,
      'cat': recipe.category,
      'ing': recipe.ingredients.map((e) => {
        'name': e.name,
        'amount': e.amount,
        'parent_menu': e.parentMenu,
      }).toList(),
    };

    List<dynamic> currentPool = List.from(room.masterRecommendPool);
    currentPool.removeWhere((item) => item['n'] == recipe.name);
    currentPool.add(newRecipeMap);

    await roomRef.update({'master_recommend_pool': currentPool});
    await incrementGlobalIngredientCount(recipe.name, recipe.ingredients.map((e) => e.name).toList());
  }

  Future<void> deleteCategory(MealRoom room, String categoryName) async {
    final roomRef = _db.collection('meal_rooms').doc(room.roomId);
    List<dynamic> currentPool = List.from(room.masterRecommendPool);
    currentPool.removeWhere((item) => item['cat'] == categoryName);
    await roomRef.update({'master_recommend_pool': currentPool});
  }

  Future<void> deleteRecipe(MealRoom room, RecipePool recipe) async {
    final roomRef = _db.collection('meal_rooms').doc(room.roomId);
    List<dynamic> currentPool = List.from(room.masterRecommendPool);
    currentPool.removeWhere((item) => item['n'] == recipe.name);
    await roomRef.update({'master_recommend_pool': currentPool});
  }

  // [장보기방 비즈니스 로직]
  Future<void> updateSharedMemo(MealRoom room, String memo) async {
    await _db.collection('meal_rooms').doc(room.roomId).update({'shared_memo': memo});
  }

 // 🎯 괄호 및 '직접 추가' 문구 유령 현상 완전 진압 버전
  Future<void> addCustomIngredientToCart(MealRoom room, String name, String amount) async {
    final roomRef = _db.collection('meal_rooms').doc(room.roomId);
    List<dynamic> currentList = List.from(room.shoppingList);
    
    currentList.add({
      'name': name,
      'amount': amount,
      'parent_menu': '', // 👈 출처 문구가 나오지 않도록 빈 문자열로 싹 비워버립니다!
      'is_purchased': false,
      'has_at_home': false,
    });
    await roomRef.update({'shopping_list': currentList});
  }

  Future<void> toggleIngredientPurchase(MealRoom room, String itemName, bool isPurchased) async {
    final roomRef = _db.collection('meal_rooms').doc(room.roomId);
    List<dynamic> currentList = List.from(room.shoppingList);
    for (var item in currentList) {
      if (item['name'] == itemName) {
        item['is_purchased'] = isPurchased;
        break;
      }
    }
    await roomRef.update({'shopping_list': currentList});
  }

  Future<void> toggleIngredientAtHome(MealRoom room, String itemName, bool hasAtHome) async {
    final roomRef = _db.collection('meal_rooms').doc(room.roomId);
    List<dynamic> currentList = List.from(room.shoppingList);
    for (var item in currentList) {
      if (item['name'] == itemName) {
        item['has_at_home'] = hasAtHome;
        break;
      }
    }
    await roomRef.update({'shopping_list': currentList});
  }

  Future<void> removeIngredientItem(MealRoom room, String itemName) async {
    final roomRef = _db.collection('meal_rooms').doc(room.roomId);
    List<dynamic> currentList = List.from(room.shoppingList);
    currentList.removeWhere((item) => item['name'] == itemName);
    await roomRef.update({'shopping_list': currentList});
  }

  Future<void> resetShoppingList(MealRoom room) async {
    await _db.collection('meal_rooms').doc(room.roomId).update({'shopping_list': []});
  }

  // [식단표 및 AI 비즈니스 로직]
  Future<void> updateMealScheduleIngredients(MealRoom room, String day, List<Map<String, dynamic>> newIngs) async {
    final schedule = Map<String, dynamic>.from(room.weeklySchedule ?? {});
    schedule[day] = {
      'menu_name': schedule[day]?['menu_name'] ?? '식단 없음',
      'ingredients': newIngs
    };
    await _db.collection('meal_rooms').doc(room.roomId).update({'weekly_schedule': schedule});
  }

  Future<void> confirmWeeklyScheduleToCart(MealRoom room) async {
    final roomRef = _db.collection('meal_rooms').doc(room.roomId);
    List<dynamic> currentCart = List.from(room.shoppingList);
    final schedule = room.weeklySchedule ?? {};

    schedule.forEach((day, data) {
      final String menuName = data['menu_name'] ?? '';
      final List<dynamic> ingredients = data['ingredients'] ?? [];
      for (var ing in ingredients) {
        currentCart.add({
          'name': ing['name'] ?? '',
          'amount': ing['amount'] ?? '적당량',
          'parent_menu': '$day요일: $menuName',
          'is_purchased': false,
          'has_at_home': false,
        });
      }
    });
    await roomRef.update({'shopping_list': currentCart});
  }

  Future<void> resetWishMenus(MealRoom room) async {
    await _db.collection('meal_rooms').doc(room.roomId).update({'wish_menus': []});
  }

  String buildSmartPrompt(String menuName, String option) {
    String constraint = "";
    if (option == "건강식") {
      constraint = """
      [STRICT RULE: HEALTHY_DIET_MODE]
      1. 절대 금지 메뉴: 부대찌개, 마라탕, 가공육(스팸/소시지), 라면사리 등 고염도/정제밀가루 요리.
      2. 재료 선택: 저염도 소금 사용, 정제 설탕 대신 올리고당/스테비아 권장, 살코기 단백질 중심.
      """;
    }
    return "메뉴 '$menuName'의 장보기 재료 리스트를 한국어로 출력해줘. $constraint";
  }

  Future<void> incrementGlobalIngredientCount(String menuName, List<String> ingredients) async {
    final batch = _db.batch();
    final recipeRef = _db.collection('global_recipes').doc(menuName);
    for (var ingName in ingredients) {
      final ingRef = recipeRef.collection('ingredients').doc(ingName);
      batch.set(ingRef, {
        'freq': FieldValue.increment(1),
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }
}