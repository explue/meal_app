import '../datasources/firebase_remote_source.dart';
import '../datasources/local_session_source.dart';
import '../../domain/models/meal_room.dart';

class MealRoomRepository {
  final FirebaseRemoteSource _remoteSource;
  final LocalSessionSource _localSource;

  MealRoomRepository({
    required FirebaseRemoteSource remoteSource,
    required LocalSessionSource localSource,
  })  : _remoteSource = remoteSource,
        _localSource = localSource;

  // Firestore 스트림을 MealRoom 도메인 모델 스트림으로 변환
  Stream<MealRoom?> watchMealRoom(String roomId) {
    return _remoteSource.streamRoom(roomId).map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return MealRoom.fromMap(snapshot.id, snapshot.data() as Map<String, dynamic>);
    });
  }

  Future<void> createNewRoom(String roomId, Map<String, dynamic> initialData) async {
    await _remoteSource.createRoom(roomId, initialData);
  }

  Future<void> updateRoomData(String roomId, Map<String, dynamic> data) async {
    await _remoteSource.updateRoom(roomId, data);
  }

  Future<bool> verifyRoomExists(String roomId) async {
    return await _remoteSource.checkRoomExists(roomId);
  }

  // 로컬 세션 관리부
  Future<String?> loadSavedRoom() => _localSource.getSavedRoomId();
  Future<void> saveRoomSession(String roomId) => _localSource.saveRoomId(roomId);
  Future<void> clearRoomSession() => _localSource.removeRoomId();

  Future<String?> loadSavedLanguage() => _localSource.getSavedLanguage();
  Future<void> saveLanguageSetting(String lang) => _localSource.saveLanguage(lang);
  Future<void> clearLanguageSetting() => _localSource.removeLanguage();
}