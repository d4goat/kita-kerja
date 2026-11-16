import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/controllers/auth_controller.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/widgets/neo_components.dart';
import 'package:provider/provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = context.read<AuthController>().getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utils.neoCream,
      appBar: AppBar(
        title: Text(
          'Daftar Pengguna',
          style: GoogleFonts.spaceGrotesk(
            color: Utils.neoBlack,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Utils.neoCream,
        elevation: 0,
        shape: const Border(bottom: Utils.borderSideW),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Utils.neoBlack),
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
              child: CircularProgressIndicator(color: Utils.neoBlack),
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
                decoration: const BoxDecoration(
                  color: Utils.neoCream,
                  borderRadius: BorderRadius.zero,
                  border: Utils.borderW,
                  boxShadow: Utils.shadowMd,
                ),
                child: Text(
                  'Data pengguna kosong',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Utils.neoBlack,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Utils.neoCream,
                  borderRadius: BorderRadius.zero,
                  border: Utils.borderW,
                  boxShadow: Utils.shadowSm,
                ),
                child: Row(
                  children: [
                    NeoAvatar(name: user['name'] ?? '', size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'] ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Utils.neoBlack,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user['email'] ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Utils.neoBlack,
                            ),
                          ),
                        ],
                      ),
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
