import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/controllers/auth_controller.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/core/database/db_exception.dart';
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
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() async {
    final auth = Provider.of<AuthController>(context, listen: false);
    final data = await auth.loadRememberMe();
    if (mounted && (data['remember'] == true) && (data['email'] as String).isNotEmpty) {
      setState(() {
        _rememberMe = true;
        _emailController.text = data['email'] as String;
      });
    }
  }

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
          await auth.saveRememberMe(email, _rememberMe);
          if (!mounted) return;
          final targetRoute = auth.initialRouteForRole;

          Utils.toast(
            context,
            'Login berhasil sebagai ${user.name} (${user.role.toUpperCase()})',
            ToastificationType.success,
            Icons.check,
            Utils.neoGreen,
          );

          await Future.delayed(const Duration(milliseconds: 400));
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, targetRoute);
        } else {
          Utils.toast(
            context,
            'Email atau kata sandi salah, silakan coba lagi.',
            ToastificationType.error,
            Icons.close,
            Utils.neoRed,
          );
        }
      } on DatabaseOfflineException catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Utils.toast(
          context,
          'Koneksi database gagal: ${e.message}',
          ToastificationType.warning,
          Icons.wifi_off_rounded,
          Utils.neoYellow,
        );
      } catch (err) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        Utils.toast(
          context,
          'Gagal melakukan autentikasi: $err',
          ToastificationType.error,
          Icons.close,
          Utils.neoRed,
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
                'Masuk ke Akun Anda',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Utils.neoBlack,
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
              const SizedBox(height: 14),
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
              const SizedBox(height: 14),
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
                      child: Text(
                        'Lupa Kata Sandi?',
                        style: GoogleFonts.inter(
                          fontSize: 12,
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
              const SizedBox(height: 20),
              NeoButton(
                text: 'LOGIN',
                isFullWidth: true,
                variant: NeoButtonVariant.primary,
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 20),

              // Quick Demo Account Helpers
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Utils.neoCream,
                  borderRadius: BorderRadius.zero,
                  border: Utils.borderWSm,
                  boxShadow: Utils.shadowSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AKUN DEMO CEPAT:',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Utils.neoBlack,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: NeoButton(
                            text: 'Admin',
                            size: NeoButtonSize.sm,
                            variant: NeoButtonVariant.neutral,
                            onPressed: () => _quickFill('admin'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: NeoButton(
                            text: 'Manager',
                            size: NeoButtonSize.sm,
                            variant: NeoButtonVariant.neutral,
                            onPressed: () => _quickFill('manager'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: NeoButton(
                            text: 'Karyawan',
                            size: NeoButtonSize.sm,
                            variant: NeoButtonVariant.neutral,
                            onPressed: () => _quickFill('employee'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
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
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
                          'Register',
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
