import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/database/index.dart';
import 'package:kita_kerja/models/auth-model.dart';
import 'package:kita_kerja/screens/forgot_password_screen.dart';
import 'package:kita_kerja/screens/forgot_password_success_screen.dart';
import 'package:kita_kerja/screens/login_screen.dart';
import 'package:kita_kerja/screens/register_screen.dart';
import 'package:kita_kerja/lib/utils.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final MySQLHelper _dbHelper = MySQLHelper();

  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _dbHelper.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utils.background,
      appBar: AppBar(
        title: const Text(
          'Daftar Pengguna',
          style: TextStyle(color: Utils.border, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: Utils.border, width: 2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Utils.border),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Utils.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Utils.border, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Utils.border,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Text(
                  'Data pengguna kosong',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Utils.border,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Utils.border, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Utils.border,
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Utils.primary,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Utils.border, width: 2),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Utils.border,
                          ),
                        ),
                        Text(
                          user['email'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
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
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/forgot-password-success': (context) =>
              const ForgotPasswordSuccessScreen(),
          '/user-list': (context) => const UserListScreen(),
        },
      ),
    );
  }
}
