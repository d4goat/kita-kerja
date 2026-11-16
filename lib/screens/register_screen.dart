import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/controllers/auth_controller.dart';
import 'package:kita_kerja/layouts/auth_layout.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/widgets/brand_header.dart';
import 'package:kita_kerja/widgets/neo_components.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

String _hashPassword(String password) {
  return BCrypt.hashpw(password, BCrypt.gensalt());
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaUsahaController = TextEditingController();
  final _namaLengkapController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
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
          Utils.neoRed,
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        String hashedPassword = await compute(
          _hashPassword,
          _passwordController.text,
        );

        if (!mounted) return;
        final success = await context.read<AuthController>().registerOwner(
          namaUsaha: _namaUsahaController.text.trim(),
          namaLengkap: _namaLengkapController.text.trim(),
          email: _emailController.text.trim(),
          password: hashedPassword,
        );

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (success) {
          Utils.toast(
            context,
            'Pendaftaran akun Owner berhasil! Silakan masuk.',
            ToastificationType.success,
            Icons.check,
            Utils.neoGreen,
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          Utils.toast(
            context,
            'Gagal mendaftarkan akun. Silakan coba lagi.',
            ToastificationType.error,
            Icons.close,
            Utils.neoRed,
          );
        }
      } catch (err) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        String errStr = err.toString();
        String msg = 'Gagal mendaftarkan akun: $errStr';

        if (errStr.contains('1062') ||
            errStr.toLowerCase().contains('duplicate entry')) {
          msg = 'Email "${_emailController.text.trim()}" sudah terdaftar. Silakan gunakan email lain.';
        }

        Utils.toast(
          context,
          msg,
          ToastificationType.error,
          Icons.close,
          Utils.neoRed,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: "Register Form",
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
                'Buat Akun Owner',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Utils.neoBlack,
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
              const SizedBox(height: 20),
              NeoButton(
                text: 'DAFTAR',
                isFullWidth: true,
                variant: NeoButtonVariant.primary,
                isLoading: _isLoading,
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Akun staf karyawan ditambahkan melalui menu Manajemen Karyawan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Utils.neoBlack,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Utils.neoBlack, thickness: 2, height: 2),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Utils.neoBlack,
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Login',
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
