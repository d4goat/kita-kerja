import 'package:flutter/material.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/lib/utils.dart';

class KaryawanScreen extends StatelessWidget {
  const KaryawanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Manajemen Karyawan',
      activeMenu: 'karyawan',
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
              Icon(Icons.people_outline, size: 64, color: Utils.primary),
              SizedBox(height: 16),
              Text(
                'Modul Karyawan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Utils.border,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Mengelola daftar karyawan, referensi jabatan, departemen, dan gaji.',
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
