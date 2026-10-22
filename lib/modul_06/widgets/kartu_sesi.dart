import 'package:flutter/material.dart';

import '../models/sesi_pengguna.dart';

class KartuSesi extends StatefulWidget {
  final SesiPengguna sesi;

  /// Waktu acuan untuk menghitung sisa masa berlaku.
  final DateTime sekarang;

  final VoidCallback? onKeluar;
  final bool sedangKeluar;
  final VoidCallback? onPerbarui;
  final bool sedangPerbarui;

  /// Menampilkan token apa adanya. Default `true`.
  final bool tampilkanToken;

  const KartuSesi({
    super.key,
    required this.sesi,
    required this.sekarang,
    this.onKeluar,
    this.sedangKeluar = false,
    this.onPerbarui,
    this.sedangPerbarui = false,
    this.tampilkanToken = true,
  });

  /// Menyamarkan token: hanya 6 karakter awal yang terlihat.
  static String samarkanToken(String token) {
    if (token.isEmpty) return '(kosong)';
    if (token.length <= 6) return _titik(token.length);
    return '${token.substring(0, 6)}${_titik(12)}';
  }

  static String _titik(int jumlah) =>
      List<String>.filled(jumlah, '\u2022').join();

  /// Mengubah `2026-09-21T10:15:00.000` menjadi `21 Sep 2026, 10:15`.
  static String formatWaktu(String iso) {
    const List<String> bulan = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final DateTime? waktu = DateTime.tryParse(iso);
    if (waktu == null) return 'tidak diketahui';
    final String jam = waktu.hour.toString().padLeft(2, '0');
    final String menit = waktu.minute.toString().padLeft(2, '0');
    return '${waktu.day} ${bulan[waktu.month - 1]} ${waktu.year}, $jam:$menit';
  }

  /// Mengubah Duration menjadi `1 jam 5 menit` / `45 detik`.
  static String formatSisa(Duration sisa) {
    if (sisa.inSeconds <= 0) return 'sudah berakhir';
    if (sisa.inMinutes < 1) return '${sisa.inSeconds} detik';
    if (sisa.inHours < 1) return '${sisa.inHours} menit';
    final int menit = sisa.inMinutes.remainder(60);
    return menit == 0
        ? '${sisa.inHours} jam'
        : '${sisa.inHours} jam $menit menit';
  }

  @override
  State<KartuSesi> createState() => _KartuSesiState();
}

class _KartuSesiState extends State<KartuSesi> {
  late bool _tampilkanToken;

  @override
  void initState() {
    super.initState();
    _tampilkanToken = widget.tampilkanToken;
  }

  @override
  void didUpdateWidget(covariant KartuSesi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tampilkanToken != widget.tampilkanToken) {
      _tampilkanToken = widget.tampilkanToken;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String tokenTampil = _tampilkanToken
        ? widget.sesi.token
        : KartuSesi.samarkanToken(widget.sesi.token);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.sesi.nama,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(widget.sesi.email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Peran: ${SesiPengguna.labelPeran(widget.sesi.peran)}'),
            Text(
              'Waktu Masuk: ${KartuSesi.formatWaktu(widget.sesi.waktuMasukIso ?? '')}',
            ),
            Text(
              'Sisa Sesi: ${KartuSesi.formatSisa(widget.sesi.sisaMasaBerlaku(widget.sekarang))}',
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Token: $tokenTampil',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 20,
                  tooltip:
                      _tampilkanToken ? 'Sembunyikan token' : 'Tampilkan token',
                  icon: Icon(
                    _tampilkanToken
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _tampilkanToken = !_tampilkanToken;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.onPerbarui != null)
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: (widget.sedangKeluar || widget.sedangPerbarui)
                          ? null
                          : widget.onPerbarui,
                      icon: widget.sedangPerbarui
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded),
                      label: Text(
                        widget.sedangPerbarui ? 'Memproses…' : 'Perbarui Sesi',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (widget.sedangKeluar || widget.sedangPerbarui)
                          ? null
                          : widget.onKeluar,
                      icon: widget.sedangKeluar
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.logout),
                      label: Text(widget.sedangKeluar ? 'Memproses…' : 'Keluar'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: widget.sedangKeluar ? null : widget.onKeluar,
                  icon: widget.sedangKeluar
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.logout),
                  label: Text(widget.sedangKeluar ? 'Memproses…' : 'Keluar'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
