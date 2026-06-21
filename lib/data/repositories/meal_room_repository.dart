import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/meal_room.dart';

class MealRoomRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🎯 파이어베이스 데이터 맵 파싱 타입 불일치 에러 완전 진압
  Future<MealRoom?> fetchMealRoom(String roomId) async {
    if (roomId.isEmpty) return null;
    final doc = await _db.collection('meal_rooms').doc(roomId).get();
    if (!doc.exists) return null;
    
    final Map<String, dynamic> data = doc.data() ?? {};
    return MealRoom.fromMap(data, roomId);
  }

  Future<void> updateMealRoomData(String roomId, Map<String, dynamic> updateData) async {
    if (roomId.isEmpty) return;
    await _db.collection('meal_rooms').doc(roomId).update(updateData);
  }
}