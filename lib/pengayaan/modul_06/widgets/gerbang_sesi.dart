import 'package:flutter/material.dart';
import '../../../modul_06/models/sesi_pengguna.dart';
import '../controllers/sesi_controller.dart';

class GerbangSesi extends StatelessWidget {
  final SesiController controller;
  final WidgetBuilder form;
  final Widget Function(BuildContext context, SesiPengguna sesi) beranda;

  const GerbangSesi({
    super.key,
    required this.controller,
    required this.form,
    required this.beranda,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) {
        if (controller.status == StatusSesi.memeriksa) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memeriksa sesi tersimpan…'),
                ],
              ),
            ),
          );
        }

        final SesiPengguna? sesi = controller.sesi;
        if (controller.status == StatusSesi.masuk && sesi != null) {
          return beranda(context, sesi);
        }

        return form(context);
      },
    );
  }
}
