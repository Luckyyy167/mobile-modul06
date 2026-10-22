import 'package:appmodul_6/modul_06/modul_06_app.dart';
import 'package:appmodul_6/modul_06/models/sesi_pengguna.dart';
import 'package:appmodul_6/modul_06/services/auth_api.dart';
import 'package:appmodul_6/modul_06/services/sesi_memori.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Fase B - Tombol Perbarui Sesi memperbarui masa berlaku sesi',
      (WidgetTester tester) async {
    final SesiMemori sesiMemori = SesiMemori();
    // Siapkan sesi aktif awal (masih berlaku)
    final SesiPengguna sesiAwal = SesiPengguna.contoh(
      sekarang: DateTime.now(),
      masaBerlaku: const Duration(hours: 2),
    );
    await sesiMemori.simpan(sesiAwal);

    await tester.pumpWidget(
      Modul06App(
        api: const AuthApi(tunda: Duration.zero),
        sesiMemori: sesiMemori,
      ),
    );
    await tester.pumpAndSettle();

    // Verifikasi bahwa tombol 'Perbarui Sesi' ada
    expect(find.text('Perbarui Sesi'), findsOneWidget);

    // Tekan tombol 'Perbarui Sesi'
    await tester.tap(find.text('Perbarui Sesi'));
    await tester.pumpAndSettle();

    // Verifikasi snackbar atau sesi diperbarui
    expect(find.text('Sesi berhasil diperbarui.'), findsOneWidget);
    expect(sesiMemori.baca(), isNotNull);
  });
}
