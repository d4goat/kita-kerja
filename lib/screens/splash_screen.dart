import 'package:flutter/material.dart';
import 'package:kita_kerja/models/auth_model.dart';
import 'package:kita_kerja/screens/dashboard_screen.dart';
import 'package:kita_kerja/screens/login_screen.dart';
import 'package:kita_kerja/widgets/ascii_preloader.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _initializeApp() async {
    // Inisialisasi awal aplikasi (misal: preload aset, cek session/token, koneksi DB)
    await Future.delayed(const Duration(milliseconds: 1200));
  }

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context, listen: false);

    return AsciiPreloader(
      minDuration: const Duration(milliseconds: 2200),
      exitPauseDuration: const Duration(milliseconds: 350),
      exitDuration: const Duration(milliseconds: 850),
      onLoad: _initializeApp,
      // Konten aplikasi yang berada di bawah preloader dan akan tersingkap saat slide up
      child: authModel.isVerified
          ? const DashboardScreen()
          : const LoginScreen(),
    );
  }
}
