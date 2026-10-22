import 'package:flutter/material.dart';
import '../../../modul_06/models/sesi_pengguna.dart';
import '../controllers/sesi_controller.dart';
import '../widgets/papan_diagnostik_penyimpanan.dart';

class BerandaPengayaanScreen extends StatefulWidget {
  final SesiController controller;
  final SesiPengguna sesi;

  const BerandaPengayaanScreen({
    super.key,
    required this.controller,
    required this.sesi,
  });

  @override
  State<BerandaPengayaanScreen> createState() => _BerandaPengayaanScreenState();
}

class _BerandaPengayaanScreenState extends State<BerandaPengayaanScreen> {
  bool _tampilkanToken = true;

  String _formatWaktu(String iso) {
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

  String _formatSisa(Duration sisa) {
    if (sisa.inSeconds <= 0) return 'sudah berakhir';
    if (sisa.inMinutes < 1) return '${sisa.inSeconds} detik';
    if (sisa.inHours < 1) return '${sisa.inHours} menit';
    final int menit = sisa.inMinutes.remainder(60);
    return menit == 0
        ? '${sisa.inHours} jam'
        : '${sisa.inHours} jam $menit menit';
  }

  String _samarkanToken(String token) {
    if (token.isEmpty) return '(kosong)';
    if (token.length <= 6) {
      return List<String>.filled(token.length, '\u2022').join();
    }
    return '${token.substring(0, 6)}${List<String>.filled(12, '\u2022').join()}';
  }

  @override
  Widget build(BuildContext context) {
    final DateTime sekarang = widget.controller.jam();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Pengayaan'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (BuildContext context, Widget? child) {
            final bool sibuk = widget.controller.sedangMemproses;
            final String tokenTampil = _tampilkanToken
                ? widget.sesi.token
                : _samarkanToken(widget.sesi.token);

            return ListView(
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                const Text(
                  'Beranda (Penyimpanan Aman)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.sesi.nama,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.sesi.email,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text('Peran: ${SesiPengguna.labelPeran(widget.sesi.peran)}'),
                        Text('Waktu Masuk: ${_formatWaktu(widget.sesi.masukPada)}'),
                        Text('Kedaluwarsa: ${_formatWaktu(widget.sesi.kedaluwarsaPada)}'),
                        Text(
                          'Sisa Sesi: ${_formatSisa(widget.sesi.sisaMasaBerlaku(sekarang))}',
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'Token: $tokenTampil',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              iconSize: 20,
                              tooltip: _tampilkanToken
                                  ? 'Sembunyikan token'
                                  : 'Tampilkan token',
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
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonalIcon(
                                onPressed: sibuk
                                    ? null
                                    : () => widget.controller.perbaruiSesi(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Perbarui Sesi'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: sibuk
                                    ? null
                                    : () => widget.controller.keluar(),
                                icon: sibuk
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.logout),
                                label: Text(sibuk ? 'Memproses…' : 'Keluar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.green.shade800),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sesi disimpan menggunakan ${widget.controller.repository.nama}. '
                          'Jika aplikasi ditutup dan dibuka kembali, sesi tetap aktif.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Papan Diagnostik Penyimpanan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.controller.repository.keterangan,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: PapanDiagnostikPenyimpanan(
                            repository: widget.controller.repository,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
