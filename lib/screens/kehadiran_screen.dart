import 'package:flutter/material.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/lib/utils.dart';

class KehadiranScreen extends StatelessWidget {
  const KehadiranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Presensi & Kehadiran',
      activeMenu: 'kehadiran',
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Utils.border, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Utils.border,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.access_time_rounded, size: 64, color: Utils.primary),
              SizedBox(height: 16),
              Text(
                'Modul Kehadiran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Utils.border,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Pencatatan masuk/pulang kerja, lembur, dan koreksi kehadiran.',
                style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
