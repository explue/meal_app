import 'package:shared_preferences/shared_preferences.dart';

class LocalSessionSource {
  static const _keyRoomId = 'saved_room_id';
  static const _keyLang = 'saved_lang';

  Future<String?> getSavedRoomId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRoomId);
  }

  Future<void> saveRoomId(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRoomId, roomId);
  }

  Future<void> removeRoomId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRoomId);
  }

  Future<String?> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLang);
  }

  Future<void> saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLang, langCode);
  }

  Future<void> removeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLang);
  }
}