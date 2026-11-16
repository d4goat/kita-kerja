import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/core/utils/utils.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const AuthLayout({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utils.neoCream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            if (!isDesktop) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: child,
                ),
              );
            }

            return Row(
              children: [
                // Section 8.1 Kiri (7/12): Panel fill Neo Blue, border-kanan 3px solid #111111
                Expanded(
                  flex: 7,
                  child: Container(
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: Utils.neoBlue,
                      border: Border(right: Utils.borderSideW),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 56,
                      vertical: 48,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Yellow geometric box accent (160x160 with border & shadow-xl)
                        SizedBox(
                          height: 400,
                          child: ClipRRect(
                            child: title.contains('Forgot')
                                ? Image.asset('assets/img/confused.png')
                                : Image.asset('assets/img/auth-icon.png'),
                          ),
                        ),
                        Utils.mediumSpace,

                        // Wordmark & Tagline
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'KERJAKITA',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 64,
                                fontWeight: FontWeight.w700,
                                color: Utils.neoCream,
                                height: 1.0,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Sistem terintegrasi presensi, tugas tim, dan manajemen beban kerja UMKM.',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Utils.neoCream,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Section 8.1 Kanan (5/12): Latar krem, kartu form di tengah vertikal, lebar 420px, shadow-lg
                Expanded(
                  flex: 5,
                  child: Container(
                    height: double.infinity,
                    color: Utils.neoCream,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    child: SingleChildScrollView(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 420),
                        width: double.infinity,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
