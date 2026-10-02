import 'package:flutter/material.dart';
import 'package:kita_kerja/layouts/auth_layout.dart';
import 'package:kita_kerja/lib/utils.dart';
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
      child: Expanded(
        child: NeoCard(
          maxWidth: 440,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandHeader(),
                const SizedBox(height: 20),
                const Text(
                  'Lupa Kata Sandi?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Utils.border,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Jangan khawatir, kami akan kirimkan anda email untuk reset password',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
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
                const SizedBox(height: 16),
                NeoButton(
                  text: 'Kirim Tautan Reset',
                  isLoading: _isLoading,
                  onPressed: _handleSendReset,
                ),
                const SizedBox(height: 16),
                Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Kembali ke Login',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
