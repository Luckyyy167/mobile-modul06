import 'package:flutter/material.dart';

enum StatusTugas { aktif, selesai }

class TugasPerforma {
  const TugasPerforma({
    required this.nomor,
    required this.mataKuliah,
    required this.status,
  });

  final int nomor;
  final String mataKuliah;
  final StatusTugas status;

  String get judul => 'Tugas praktikum ${nomor.toString().padLeft(4, '0')}';
}

class Modul11App extends StatelessWidget {
  const Modul11App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Modul 11 — Optimasi Daftar Tugas',
        debugShowCheckedModeBanner: true,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF0E7490),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const LayarDaftarTugasPerforma(),
      );
}

class LayarDaftarTugasPerforma extends StatefulWidget {
  const LayarDaftarTugasPerforma({super.key});

  @override
  State<LayarDaftarTugasPerforma> createState() =>
      _LayarDaftarTugasPerformaState();
}

class _LayarDaftarTugasPerformaState extends State<LayarDaftarTugasPerforma> {
  final TextEditingController _pencarian = TextEditingController();
  final List<TugasPerforma> _semuaTugas = List<TugasPerforma>.generate(
    1000,
    (index) => TugasPerforma(
      nomor: index + 1,
      mataKuliah: const [
        'Pemrograman Mobile',
        'Basis Data',
        'Jaringan Komputer',
        'Rekayasa Perangkat Lunak',
        'Sistem Operasi',
        'Kecerdasan Buatan',
        'Pemrograman Web',
        'Analisis dan Perancangan Sistem',
      ][index % 8],
      status: (index + 1) % 4 == 0 ? StatusTugas.selesai : StatusTugas.aktif,
    ),
  );
  StatusTugas? _filter;
  String _kueri = '';

  List<TugasPerforma> get _hasil {
    // Kueri cukup diubah ke huruf kecil sekali per build, bukan sekali per item.
    final kueri = _kueri.toLowerCase();
    return _semuaTugas.where((tugas) {
      final cocokStatus = _filter == null || tugas.status == _filter;
      final cocokTeks =
          '${tugas.judul} ${tugas.mataKuliah}'.toLowerCase().contains(kueri);
      return cocokStatus && cocokTeks;
    }).toList(growable: false);
  }

  @override
  void dispose() {
    _pencarian.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasil = _hasil;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tugas Kuliah'),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              key: const ValueKey('task-search'),
              controller: _pencarian,
              onChanged: (value) => setState(() => _kueri = value),
              decoration: InputDecoration(
                hintText: 'Cari tugas atau mata kuliah',
                hintStyle: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFF0E7490), width: 1.5),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                _filterChip('Semua', null),
                _filterChip('Aktif', StatusTugas.aktif),
                _filterChip('Selesai', StatusTugas.selesai),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Menampilkan ${hasil.length} dari ${_semuaTugas.length} tugas',
              key: const ValueKey('result-count'),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
              ),
            ),
          ),
          Expanded(
            child: hasil.isEmpty
                ? const Center(child: Text('Tidak ada tugas yang cocok.'))
                : ListView.builder(
                    key: const ValueKey('task-list'),
                    itemCount: hasil.length,
                    itemBuilder: (context, index) =>
                        _KartuTugas(tugas: hasil[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, StatusTugas? status) {
    final isSelected = _filter == status;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF1E293B),
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      showCheckmark: true,
      checkmarkColor: const Color(0xFF1E293B),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFFE2E8F0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.transparent : const Color(0xFFCBD5E1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onSelected: (selected) {
        setState(() {
          if (status == null) {
            _filter = null;
          } else {
            _filter = selected ? status : null;
          }
        });
      },
    );
  }
}

class _KartuTugas extends StatelessWidget {
  const _KartuTugas({required this.tugas});

  final TugasPerforma tugas;

  @override
  Widget build(BuildContext context) => Card(
        key: ValueKey('task-card-${tugas.nomor}'),
        elevation: 0,
        color: const Color(0xFFF1F5F9),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFBAE6FD),
            radius: 20,
            child: Icon(
              Icons.assignment_outlined,
              color: Color(0xFF0284C7),
              size: 22,
            ),
          ),
          title: Text(
            tugas.judul,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          subtitle: Text(
            tugas.mataKuliah,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          trailing: Text(
            tugas.status == StatusTugas.selesai ? 'Selesai' : 'Aktif',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      );
}

