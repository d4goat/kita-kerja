import 'package:flutter/material.dart';
import 'package:kita_kerja/database/index.dart';
import 'package:kita_kerja/layouts/auth_layout.dart';
import 'package:kita_kerja/lib/utils.dart';
import 'package:kita_kerja/widgets/brand_header.dart';
import 'package:kita_kerja/widgets/neo_components.dart';
import 'package:toastification/toastification.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaUsahaController = TextEditingController();
  final _namaLengkapController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final MySQLHelper _dbHelper = MySQLHelper();
  bool _isLoading = false;

  @override
  void dispose() {
    _namaUsahaController.dispose();
    _namaLengkapController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text != _confirmPasswordController.text) {
        Utils.toast(
          context,
          'Konfirmasi kata sandi tidak sesuai!',
          ToastificationType.error,
          Icons.close,
          Utils.danger,
        );
        return;
      }

      setState(() => _isLoading = true);

      final success = await _dbHelper.registerOwner(
        namaUsaha: _namaUsahaController.text.trim(),
        namaLengkap: _namaLengkapController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        Utils.toast(
          context,
          'Pendaftaran akun Owner berhasil! SIlahkan masuk.',
          ToastificationType.success,
          Icons.check,
          Utils.success,
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Utils.toast(
          context,
          'Gagal mendaftarkan akun. Silahkan coba lagi.',
          ToastificationType.error,
          Icons.close,
          Utils.danger,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Register Form",
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
                  'Buat Akun Owner',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Utils.border,
                  ),
                ),
                const SizedBox(height: 16),
                NeoTextField(
                  label: 'Nama Usaha',
                  placeholder: 'misal: CV Maju Jaya Makmur',
                  controller: _namaUsahaController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama usaha wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                NeoTextField(
                  label: 'Nama Lengkap',
                  placeholder: 'Nama lengkap pemilik usaha',
                  controller: _namaLengkapController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama lengkap wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
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
                  placeholder: 'Minimal 8 karakter',
                  controller: _passwordController,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.length < 8) {
                      return 'Kata sandi minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                NeoTextField(
                  label: 'Konfirmasi Kata Sandi',
                  placeholder: 'Ulangi kata sandi',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Konfirmasi kata sandi wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                NeoButton(
                  text: 'Buat Akun Owner',
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Akun karyawan dibuat oleh Owner/Admin',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE5E5E5), height: 1),
                const SizedBox(height: 14),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
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
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Masuk',
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
