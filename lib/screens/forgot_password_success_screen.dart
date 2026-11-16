import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/layouts/auth_layout.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/widgets/neo_components.dart';

class ForgotPasswordSuccessScreen extends StatelessWidget {
  const ForgotPasswordSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Forgot Password Success Form",
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: const BoxDecoration(
          color: Utils.neoCream,
          borderRadius: BorderRadius.zero,
          border: Utils.borderW,
          boxShadow: Utils.shadowLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Utils.neoGreen,
                borderRadius: BorderRadius.zero,
                border: Utils.borderW,
                boxShadow: Utils.shadowMd,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.check, color: Utils.neoBlack, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              'Tautan Reset Terkirim',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Utils.neoBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Periksa kotak masuk email Anda untuk membuka tautan pemulihan kata sandi.',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Utils.neoBlack,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            NeoButton(
              text: 'KEMBALI KE LOGIN',
              isFullWidth: true,
              variant: NeoButtonVariant.primary,
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
    );
  }
}
