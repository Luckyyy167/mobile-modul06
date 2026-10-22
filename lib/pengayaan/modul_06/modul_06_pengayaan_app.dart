import 'package:flutter/material.dart';

// Ganti 'appmodul_6' sesuai nama project di pubspec.yaml Anda
import 'package:appmodul_6/modul_06/models/sesi_pengguna.dart';
import 'package:appmodul_6/modul_06/services/auth_api.dart';
import 'package:appmodul_6/pengayaan/modul_06/controllers/sesi_controller.dart';
import 'package:appmodul_6/pengayaan/modul_06/repositories/aman_sesi_repository.dart';
import 'package:appmodul_6/pengayaan/modul_06/screens/beranda_pengayaan_screen.dart';
import 'package:appmodul_6/pengayaan/modul_06/screens/login_pengayaan_screen.dart';
import 'package:appmodul_6/pengayaan/modul_06/storage/penyimpanan_aman_platform.dart';
import 'package:appmodul_6/pengayaan/modul_06/widgets/gerbang_sesi.dart';

class Modul06PengayaanApp extends StatefulWidget {
  const Modul06PengayaanApp({super.key});

  @override
  State<Modul06PengayaanApp> createState() => _Modul06PengayaanAppState();
}

class _Modul06PengayaanAppState extends State<Modul06PengayaanApp> {
  late final AuthApi _api = const AuthApi();

  late final SesiController _kendali = SesiController(
    api: _api,
    repository: AmanSesiRepository(
      penyimpanan: PenyimpananAmanPlatform(),
    ),
  );

  @override
  void initState() {
    super.initState();
    _kendali.pulihkan();
  }

  @override
  void dispose() {
    _kendali.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modul 06 - Login dan Session',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
        ),
        useMaterial3: true,
      ),
      home: GerbangSesi(
        controller: _kendali,
        form: (BuildContext context) =>
            LoginPengayaanScreen(controller: _kendali),
        beranda: (BuildContext context, SesiPengguna sesi) =>
            BerandaPengayaanScreen(controller: _kendali, sesi: sesi),
      ),
    );
  }
}

