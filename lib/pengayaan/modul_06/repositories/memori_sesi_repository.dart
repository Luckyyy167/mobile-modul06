import '../../../modul_06/models/sesi_pengguna.dart';
import 'sesi_repository.dart';

class MemoriSesiRepository implements SesiRepository {
  SesiPengguna? _sesi;

  @override
  String get nama => 'Penyimpanan Memori';

  @override
  String get keterangan =>
      'Disimpan hanya di memori RAM proses. Sesi hilang begitu aplikasi ditutup.';

  @override
  bool get bertahanSetelahRestart => false;

  @override
  Future<SesiPengguna?> baca() async => _sesi;

  @override
  Future<void> simpan(SesiPengguna sesi) async {
    _sesi = sesi;
  }

  @override
  Future<void> hapus() async {
    _sesi = null;
  }

  @override
  Future<bool> adaSesi() async => _sesi != null;

  @override
  Future<String?> intipMentah() async => _sesi?.token;
}
