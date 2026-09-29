import 'package:flutter/material.dart';
import 'package:kita_kerja/layouts/auth_layout.dart';
import 'package:kita_kerja/lib/utils.dart';
import 'package:kita_kerja/widgets/neo_components.dart';

class ForgotPasswordSuccessScreen extends StatelessWidget {
  const ForgotPasswordSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Forgot Password Success Form",
      child: Expanded(
        child: NeoCard(
          maxWidth: 360,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Utils.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Utils.border, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Utils.border,
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.check, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tautan Reset Terkirim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Utils.border,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Periksa email Anda untuk tautan reset kata sandi.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              NeoButton(
                text: 'Kembali ke Login',
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
