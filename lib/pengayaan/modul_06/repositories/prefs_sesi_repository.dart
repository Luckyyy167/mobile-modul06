// Bungkus ke dalam class agar annotation @override valid
class PrefsSesiRepository {
  // 1. Definisi kunciSesi untuk menyimpan key preferensi
  static const String kunciSesi = 'sesi_token';

  // 2. Definisi _prefs untuk mengambil instance SharedPreferences
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<String?> intipMentah() async {
    final SharedPreferences prefs = await _prefs;
    // Demonstrasi ini memperlihatkan bahwa adapter preferensi dapat
    // mengembalikan nilai token melalui API biasa.
    return prefs.getString(kunciSesi);
  }
}
class SharedPreferences {
  static Future<SharedPreferences> getInstance() async {
    throw UnimplementedError();
  }

  Future<String?> getString(String kunciSesi) async {
    throw UnimplementedError();
  }
}