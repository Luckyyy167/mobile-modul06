import 'package:flutter/material.dart';
import '../models/sesi_pengguna.dart';
import '../services/auth_api.dart';
import '../services/sesi_memori.dart';
import '../widgets/field_kata_sandi.dart';

enum StatusAuth { memeriksa, keluar, memproses, masuk, gagal }

class LoginScreen extends StatefulWidget {
  final AuthApi api;
  final SesiMemori sesiMemori;
  final DateTime Function() jam;

  const LoginScreen({
    super.key,
    required this.api,
    required this.sesiMemori,
    this.jam = DateTime.now,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _sandi = TextEditingController();

  StatusAuth _status = StatusAuth.memeriksa;
  String? _pesanGagal;
  SesiPengguna? _sesi;
  bool _sedangKeluar = false;
  bool _sedangPerbarui = false;

  @override
  void initState() {
    super.initState();
    _pulihkanSesi();
  }

  @override
  void dispose() {
    _email.dispose();
    _sandi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modul 06 — Login & Session Dasar'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(child: _bangunIsi()),
    );
  }

  /// Satu-satunya tempat yang memutuskan layar mana yang tampil.
  Widget _bangunIsi() {
    switch (_status) {
      case StatusAuth.memeriksa:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memeriksa sesi tersimpan…'),
            ],
          ),
        );
      case StatusAuth.masuk:
        final SesiPengguna? sesi = _sesi;
        if (sesi == null) {
          return _bangunForm();
        }
        return _bangunBeranda(sesi);
      case StatusAuth.keluar:
      case StatusAuth.memproses:
      case StatusAuth.gagal:
        return _bangunForm();
    }
  }

  Widget _bangunForm() {
    final bool sibuk = _status == StatusAuth.memproses;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        const SizedBox(height: 8),
        const Text(
          'Masuk ke Portal Akademik',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        if (_pesanGagal != null) ...<Widget>[
          _KotakPesan(pesan: _pesanGagal!),
          const SizedBox(height: 16),
        ],
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _email,
                enabled: !sibuk,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.email],
                validator: _validasiEmail,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FieldKataSandi(
                controller: _sandi,
                enabled: !sibuk,
                validator: (String? nilai) {
                  if (nilai == null || nilai.isEmpty) {
                    return 'Kata sandi wajib diisi.';
                  }
                  if (nilai.length < 8) {
                    return 'Kata sandi minimal 8 karakter.';
                  }
                  return null;
                },
                onSubmitted: _kirim,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: sibuk ? null : _kirim,
            icon: sibuk
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.login_rounded),
            label: Text(sibuk ? 'Memproses…' : 'Masuk'),
          ),
        ),
        const SizedBox(height: 12),
        _KotakInfoDemo(
          onIsiOtomatis: sibuk
              ? null
              : () => setState(() {
            _email.text = AuthApi.emailDemo;
            _sandi.text = AuthApi.sandiDemo;
          }),
        ),
      ],
    );
  }

  static String? _validasiEmail(String? nilai) {
    final String teks = (nilai ?? '').trim();
    if (teks.isEmpty) return 'Email wajib diisi.';
    if (!teks.contains('@') || !teks.contains('.')) {
      return 'Format email belum benar.';
    }
    return null;
  }

  Widget _bangunBeranda(SesiPengguna sesi) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        const Text(
          'Beranda',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        KartuSesi(
          sesi: sesi,
          sekarang: widget.jam(),
          onKeluar: _keluar,
          sedangKeluar: _sedangKeluar,
          onPerbarui: _perbaruiSesi,
          sedangPerbarui: _sedangPerbarui,
        ),
        const SizedBox(height: 20),
        const _KotakPeringatanMemori(),
      ],
    );
  }

  Future<void> _pulihkanSesi() async {
    final SesiPengguna? tersimpan = widget.sesiMemori.baca();
    if (!mounted) return;

    if (tersimpan == null) {
      setState(() => _status = StatusAuth.keluar);
      return;
    }

    if (tersimpan.sudahKedaluwarsa(widget.jam())) {
      await widget.sesiMemori.hapus();
      if (!mounted) return;
      setState(() {
        _status = StatusAuth.gagal;
        _pesanGagal = 'Sesi sebelumnya sudah berakhir. Silakan masuk lagi.';
      });
      return;
    }

    setState(() {
      _sesi = tersimpan;
      _status = StatusAuth.masuk;
    });
  }

  Future<void> _kirim() async {
    if (_status == StatusAuth.memproses) return;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _status = StatusAuth.memproses;
      _pesanGagal = null;
    });

    try {
      final SesiPengguna hasil = await widget.api.masuk(
        email: _email.text,
        sandi: _sandi.text,
      );
      await widget.sesiMemori.simpan(hasil);
      if (!mounted) return;
      setState(() {
        _sesi = hasil;
        _status = StatusAuth.masuk;
        _sandi.clear();
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _status = StatusAuth.gagal;
        _pesanGagal = e.pesan;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = StatusAuth.gagal;
        _pesanGagal = 'Terjadi kesalahan tak terduga. Coba lagi.';
      });
      debugPrint('Login gagal tak terduga: $e');
    }
  }

  Future<void> _keluar() async {
    setState(() => _sedangKeluar = true);
    await widget.sesiMemori.hapus();
    if (!mounted) return;
    setState(() {
      _sesi = null;
      _status = StatusAuth.keluar;
      _pesanGagal = null;
      _sedangKeluar = false;
      _email.clear();
      _sandi.clear();
    });
  }

  Future<void> _perbaruiSesi() async {
    final SesiPengguna? sekarang = _sesi;
    if (sekarang == null || _sedangPerbarui) return;

    if (sekarang.sudahKedaluwarsa(widget.jam())) {
      await widget.sesiMemori.hapus();
      if (!mounted) return;
      setState(() {
        _sesi = null;
        _status = StatusAuth.gagal;
        _pesanGagal = 'Sesi sudah berakhir dan tidak dapat diperbarui.';
      });
      return;
    }

    setState(() => _sedangPerbarui = true);

    try {
      final SesiPengguna diperbarui = await widget.api.perbaruiSesi(sekarang);
      await widget.sesiMemori.simpan(diperbarui);
      if (!mounted) return;
      setState(() {
        _sesi = diperbarui;
        _sedangPerbarui = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi berhasil diperbarui.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _sedangPerbarui = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui sesi: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class KartuSesi extends StatefulWidget {
  final SesiPengguna sesi;
  final DateTime sekarang;
  final VoidCallback? onKeluar;
  final bool sedangKeluar;
  final VoidCallback? onPerbarui;
  final bool sedangPerbarui;
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

class _KotakPesan extends StatelessWidget {
  final String pesan;

  const _KotakPesan({required this.pesan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              pesan,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KotakInfoDemo extends StatelessWidget {
  final VoidCallback? onIsiOtomatis;

  const _KotakInfoDemo({this.onIsiOtomatis});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Akun Demo:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('Email: ${AuthApi.emailDemo}'),
            const Text('Sandi: ${AuthApi.sandiDemo}'),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onIsiOtomatis,
                child: const Text('Isi Otomatis'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KotakPeringatanMemori extends StatelessWidget {
  const _KotakPeringatanMemori();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade700),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Sesi ini hanya ada di memori proses. Tutup aplikasi dari daftar '
                  'aplikasi terakhir, lalu buka lagi — sesi akan hilang. Itu hasil yang diharapkan.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}