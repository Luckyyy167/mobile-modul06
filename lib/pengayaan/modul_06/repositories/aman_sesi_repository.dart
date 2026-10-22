import 'dart:convert';
import '../../../modul_06/models/sesi_pengguna.dart';
import '../storage/penyimpanan_aman.dart';
import 'sesi_repository.dart';

class AmanSesiRepository implements SesiRepository {
  static const String kunciSesiDefault = 'sesi_pengguna';

  final PenyimpananAman penyimpanan;
  final String kunciSesi;

  const AmanSesiRepository({
    required this.penyimpanan,
    this.kunciSesi = kunciSesiDefault,
  });

  @override
  String get nama => 'Penyimpanan Aman (Platform)';

  @override
  String get keterangan =>
      'Disimpan secara terenkripsi (Keychain / KeyStore). Bertahan setelah aplikasi ditutup.';

  @override
  bool get bertahanSetelahRestart => true;

  @override
  Future<SesiPengguna?> baca() async {
    final String? raw = await penyimpanan.baca(kunciSesi);
    if (raw == null || raw.isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return SesiPengguna.fromJson(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> simpan(SesiPengguna sesi) async {
    final String raw = jsonEncode(sesi.toJson());
    await penyimpanan.tulis(kunciSesi, raw);
  }

  @override
  Future<void> hapus() async {
    await penyimpanan.hapus(kunciSesi);
  }

  @override
  Future<bool> adaSesi() async {
    final SesiPengguna? sesi = await baca();
    return sesi != null;
  }

  @override
  Future<String?> intipMentah() async {
    // Adapter tidak menyediakan pembacaan mentah melalui API aplikasi.
    return await penyimpanan.bacaMentah(kunciSesi);
  }
}