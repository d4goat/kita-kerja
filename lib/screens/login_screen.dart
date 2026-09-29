import 'package:flutter/material.dart';
import 'package:kita_kerja/layouts/auth_layout.dart';
import 'package:kita_kerja/lib/utils.dart';
import 'package:kita_kerja/widgets/brand_header.dart';
import 'package:kita_kerja/widgets/neo_components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login berhasil! Mengarahkan ke Dashboard...'),
          backgroundColor: Utils.success,
        ),
      );
      Navigator.pushReplacementNamed(context, '/user-list');
    }
  }

  @override
  Widget build(BuildContext context) {
    Utils().init(context);
    return AuthLayout(
      title: 'Login Form',
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
                  'Masuk ke Akun Anda',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Utils.border,
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
                const SizedBox(height: 12),
                NeoTextField(
                  label: 'Kata Sandi',
                  placeholder: 'Masukkan kata sandi',
                  controller: _passwordController,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Kata sandi wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NeoCheckbox(
                      value: _rememberMe,
                      onChanged: (val) => setState(() => _rememberMe = val),
                      label: 'Ingat Saya',
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        child: const Text(
                          'Lupa Kata Sandi?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Utils.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                NeoButton(
                  text: 'Masuk',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun? ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Utils.border,
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            'Daftar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Utils.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
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
