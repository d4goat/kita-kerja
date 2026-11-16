import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/layouts/auth_layout.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/widgets/brand_header.dart';
import 'package:kita_kerja/widgets/neo_components.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushReplacementNamed(context, '/forgot-password-success');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Forgot Password Form",
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Utils.neoCream,
          borderRadius: BorderRadius.zero,
          border: Utils.borderW,
          boxShadow: Utils.shadowLg,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandHeader(),
              const SizedBox(height: 20),
              Text(
                'Lupa Kata Sandi?',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Utils.neoBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masukkan email Anda untuk menerima tautan pemulihan kata sandi akun.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Utils.neoBlack,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              NeoTextField(
                label: 'Email',
                placeholder: 'nama@perusahaan.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Email wajib diisi';
                  }
                  if (!val.contains('@')) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              NeoButton(
                text: 'KIRIM TAUTAN',
                isFullWidth: true,
                variant: NeoButtonVariant.primary,
                isLoading: _isLoading,
                onPressed: _handleSendReset,
              ),
              const SizedBox(height: 20),
              Center(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Kembali ke Login',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Utils.neoBlack,
                        decoration: TextDecoration.underline,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
