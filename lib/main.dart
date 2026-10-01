import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/lib/utils.dart';
import 'package:kita_kerja/models/auth_model.dart';
import 'package:kita_kerja/screens/dashboard_screen.dart';
import 'package:kita_kerja/screens/forgot_password_screen.dart';
import 'package:kita_kerja/screens/forgot_password_success_screen.dart';
import 'package:kita_kerja/screens/karyawan_form_screen.dart';
import 'package:kita_kerja/screens/karyawan_screen.dart';
import 'package:kita_kerja/screens/kehadiran_screen.dart';
import 'package:kita_kerja/screens/login_screen.dart';
import 'package:kita_kerja/screens/master_data_screen.dart';
import 'package:kita_kerja/screens/pekerjaan_screen.dart';
import 'package:kita_kerja/screens/profile_screen.dart';
import 'package:kita_kerja/screens/register_screen.dart';
import 'package:kita_kerja/screens/user_list_screen.dart';
import 'package:kita_kerja/widgets/svg_transition.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthModel(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'KerjaKita',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Utils.background,
          textTheme: GoogleFonts.spaceGroteskTextTheme(
            Theme.of(context).textTheme,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            focusColor: Utils.primary,
            border: Utils.outlinedBorder,
            focusedBorder: Utils.focusBorder,
            errorBorder: Utils.errorBorder,
            enabledBorder: Utils.outlinedBorder,
            floatingLabelStyle: TextStyle(color: Utils.border),
            prefixIconColor: Utils.border,
          ),
        ),
        initialRoute: '/login',
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/login':
              page = const LoginScreen();
              break;
            case '/register':
              page = const RegisterScreen();
              break;
            case '/forgot-password':
              page = const ForgotPasswordScreen();
              break;
            case '/forgot-password-success':
              page = const ForgotPasswordSuccessScreen();
              break;
            case '/dashboard':
              page = const DashboardScreen();
              break;
            case '/master-data':
              page = const MasterDataScreen();
              break;
            case '/profile':
              page = const ProfileScreen();
              break;
            case '/karyawan':
              page = const KaryawanScreen();
              break;
            case '/karyawan-form':
              page = const KaryawanFormScreen();
              break;
            case '/kehadiran':
              page = const KehadiranScreen();
              break;
            case '/pekerjaan':
              page = const PekerjaanScreen();
              break;
            case '/user-list':
              page = const UserListScreen();
              break;
            default:
              page = const LoginScreen();
          }

          return PageRouteBuilder(
            settings: settings,
            transitionDuration: const Duration(milliseconds: 2400),
            reverseTransitionDuration: const Duration(milliseconds: 2200),
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: const Interval(
                              0.45,
                              0.55,
                              curve: Curves.easeIn,
                            ),
                          ),
                        ),
                        child: child,
                      ),
                      SvgPathTransition(animation: animation),
                    ],
                  );
                },
          );
        },
      ),
    );
  }
}
