import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRemoteSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 특정 방의 실시간 데이터 스트림 가져오기
  Stream<DocumentSnapshot> streamRoom(String roomId) {
    return _firestore.collection('meal_rooms').doc(roomId).snapshots();
  }

  // 새로운 장보기 방 생성하기
  Future<void> createRoom(String roomId, Map<String, dynamic> initialData) async {
    await _firestore.collection('meal_rooms').doc(roomId).set(initialData);
  }

  // 방 데이터 업데이트하기
  Future<void> updateRoom(String roomId, Map<String, dynamic> data) async {
    await _firestore.collection('meal_rooms').doc(roomId).update(data);
  }

  // 방 존재 여부 확인하기
  Future<bool> checkRoomExists(String roomId) async {
    final doc = await _firestore.collection('meal_rooms').doc(roomId).get();
    return doc.exists;
  }
}