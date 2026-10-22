import 'package:flutter/material.dart';
import '../repositories/sesi_repository.dart';

class PapanDiagnostikPenyimpanan extends StatefulWidget {
  final SesiRepository repository;

  const PapanDiagnostikPenyimpanan({super.key, required this.repository});

  @override
  State<PapanDiagnostikPenyimpanan> createState() =>
      _PapanDiagnostikPenyimpananState();
}

class _PapanDiagnostikPenyimpananState
    extends State<PapanDiagnostikPenyimpanan> {
  String? _hasilIntip;
  bool _sudahMengintip = false;
  bool _sedangMengintip = false;

  Future<void> _intip() async {
    setState(() => _sedangMengintip = true);

    final String? hasil = await widget.repository.intipMentah();

    if (!mounted) return;

    setState(() {
      _hasilIntip = hasil;
      _sudahMengintip = true;
      _sedangMengintip = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: _sedangMengintip ? null : _intip,
          icon: const Icon(Icons.search_rounded),
          label: Text(_sedangMengintip ? 'Memproses...' : 'Intip Data'),
        ),
        if (_sudahMengintip) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Hasil: ${_hasilIntip ?? "(null - data aman tidak terbaca langsung)"}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}
