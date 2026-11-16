import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/controllers/attendance_controller.dart';
import 'package:kita_kerja/controllers/auth_controller.dart';
import 'package:kita_kerja/controllers/dashboard_controller.dart';
import 'package:kita_kerja/controllers/employee_controller.dart';
import 'package:kita_kerja/controllers/master_data_controller.dart';
import 'package:kita_kerja/controllers/salary_controller.dart';
import 'package:kita_kerja/controllers/task_controller.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/screens/dashboard_screen.dart';
import 'package:kita_kerja/screens/forgot_password_screen.dart';
import 'package:kita_kerja/screens/forgot_password_success_screen.dart';
import 'package:kita_kerja/screens/karyawan_form_screen.dart';
import 'package:kita_kerja/screens/karyawan_screen.dart';
import 'package:kita_kerja/screens/kehadiran_screen.dart';
import 'package:kita_kerja/screens/login_screen.dart';
import 'package:kita_kerja/screens/pekerjaan_form_screen.dart';
import 'package:kita_kerja/screens/pekerjaan_screen.dart';
import 'package:kita_kerja/screens/settings_screen.dart';
import 'package:kita_kerja/screens/register_screen.dart';
import 'package:kita_kerja/screens/splash_screen.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => AttendanceController()),
        ChangeNotifierProvider(create: (_) => TaskController()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => EmployeeController()),
        ChangeNotifierProvider(create: (_) => SalaryController()),
        ChangeNotifierProvider(create: (_) => MasterDataController()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'KerjaKita',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Utils.neoCream,
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          textTheme: GoogleFonts.interTextTheme(
            Theme.of(context).textTheme,
          ).apply(
            bodyColor: Utils.neoBlack,
            displayColor: Utils.neoBlack,
          ),
          cardTheme: const CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            color: Utils.neoCream,
          ),
          dialogTheme: const DialogThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: Utils.borderSideW,
            ),
            backgroundColor: Utils.neoCream,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Utils.neoCream,
            focusColor: Utils.neoBlack,
            border: Utils.outlinedBorder,
            focusedBorder: Utils.focusBorder,
            errorBorder: Utils.errorBorder,
            enabledBorder: Utils.outlinedBorder,
            floatingLabelStyle: TextStyle(color: Utils.neoBlack),
            prefixIconColor: Utils.neoBlack,
            suffixIconColor: Utils.neoBlack,
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/':
            case '/splash':
              page = const SplashScreen();
              break;
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
            case '/pengaturan':
            case '/settings':
              final initialTab = (settings.arguments is int) ? (settings.arguments as int) : 0;
              page = SettingsScreen(initialTab: initialTab);
              break;
            case '/master-data':
              page = const SettingsScreen(initialTab: 1);
              break;
            case '/profile':
              page = const SettingsScreen(initialTab: 0);
              break;
            case '/karyawan':
              page = const KaryawanScreen();
              break;
            case '/karyawan-form':
              final args = settings.arguments as Map<String, dynamic>?;
              page = KaryawanFormScreen(employeeToEdit: args);
              break;
            case '/kehadiran':
              page = const KehadiranScreen();
              break;
            case '/pekerjaan':
              page = const PekerjaanScreen();
              break;
            case '/pekerjaan-form':
              final args = settings.arguments as Map<String, dynamic>?;
              page = PekerjaanFormScreen(taskToEdit: args);
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
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: const Interval(0.45, 0.55, curve: Curves.easeIn),
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
