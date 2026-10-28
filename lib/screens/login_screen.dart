import 'package:flutter/material.dart';
import 'package:kita_kerja/controllers/auth_controller.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/database/db_exception.dart';
import 'package:kita_kerja/layouts/auth_layout.dart';
import 'package:kita_kerja/widgets/brand_header.dart';
import 'package:kita_kerja/widgets/neo_components.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  bool _rememberMe = true;
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

      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final auth = Provider.of<AuthController>(context, listen: false);

      try {
        final user = await auth.login(email, password);

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (user != null) {
          final targetRoute = auth.initialRouteForRole;

          Utils.toast(
            context,
            'Login berhasil sebagai ${user.name} (${user.role.toUpperCase()})!\nNavigasi otomatis ke: $targetRoute',
            ToastificationType.success,
            Icons.check,
            Utils.success,
          );

          await Future.delayed(const Duration(milliseconds: 600));
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, targetRoute);
        } else {
          Utils.toast(
            context,
            'Email atau kata sandi salah, silakan coba lagi.',
            ToastificationType.error,
            Icons.close,
            Utils.danger,
          );
        }
      } on DatabaseOfflineException catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Utils.toast(
          context,
          'Koneksi database gagal.\n${e.message}',
          ToastificationType.warning,
          Icons.wifi_off_rounded,
          Utils.warning,
        );
      } catch (err) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        Utils.toast(
          context,
          'Gagal melakukan autentikasi: $err',
          ToastificationType.error,
          Icons.close,
          Utils.danger,
        );
      }
    }
  }

  void _quickFill(String role) {
    if (role == 'admin') {
      _emailController.text = 'admin@kerjakita.local';
      _passwordController.text = 'password';
    } else if (role == 'manager') {
      _emailController.text = 'manager@kerjakita.local';
      _passwordController.text = 'password';
    } else if (role == 'employee') {
      _emailController.text = 'citra@kerjakita.local';
      _passwordController.text = 'password';
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
                const SizedBox(height: 16),
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
                  placeholder: 'admin@kerjakita.local / citra@...',
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
                const SizedBox(height: 16),

                // Quick Demo Account Helpers
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F1E8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Utils.border, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Akun Demo (Klik untuk isi cepat):',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Utils.border),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _quickFill('admin'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Utils.border, width: 1.5),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              ),
                              child: const Text('Admin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Utils.border)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _quickFill('manager'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Utils.border, width: 1.5),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              ),
                              child: const Text('Manager', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Utils.border)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _quickFill('employee'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Utils.border, width: 1.5),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              ),
                              child: const Text('Karyawan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Utils.border)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
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
