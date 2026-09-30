import 'package:flutter/material.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/lib/utils.dart';
import 'package:kita_kerja/models/auth-model.dart';
import 'package:kita_kerja/widgets/neo_components.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthModel>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.name ?? 'Hendra Wijaya');
    _emailController = TextEditingController(text: user?.email ?? 'hendra@kerjakita.com');
    _phoneController = TextEditingController(text: user?.phone ?? '081234567890');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSaveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      Provider.of<AuthModel>(context, listen: false).updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil Anda berhasil diperbarui!'),
          backgroundColor: Utils.success,
        ),
      );
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Utils.border, width: 2),
          ),
          title: Row(
            children: const [
              Icon(Icons.logout, color: Utils.danger),
              SizedBox(width: 8),
              Text(
                'Konfirmasi Logout',
                style: TextStyle(fontWeight: FontWeight.w800, color: Utils.border),
              ),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi KerjaKita?',
            style: TextStyle(color: Utils.border),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Utils.border, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Batal', style: TextStyle(color: Utils.border)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Provider.of<AuthModel>(context, listen: false).logout();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Utils.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Utils.border, width: 2),
                ),
              ),
              child: const Text('Ya, Keluar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthModel>(context);
    final user = auth.currentUser;
    final name = user?.name ?? 'Hendra Wijaya';
    final email = user?.email ?? 'hendra@kerjakita.com';
    final role = (user?.role ?? 'admin').toUpperCase();

    return MainLayout(
      title: 'Profil Saya',
      activeMenu: 'profile',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Card: User Info Summary & Logout
            Expanded(
              flex: 1,
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
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Utils.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Utils.border, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Utils.border,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Utils.border,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Utils.secondary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Utils.border, width: 1.5),
                      ),
                      child: Text(
                        role,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Utils.border,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFEEEEEE), height: 1),
                    const SizedBox(height: 24),
                    NeoButton(
                      text: 'Keluar dari Sistem (Logout)',
                      backgroundColor: Utils.danger,
                      textColor: Colors.white,
                      onPressed: () => _showLogoutConfirmation(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Right Card: Update Profile Details Form
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(28),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Akun',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Utils.border,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Perbarui informasi pribadi dan kontak akun Anda.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                      ),
                      const SizedBox(height: 20),
                      NeoTextField(
                        label: 'Nama Lengkap',
                        placeholder: 'Masukkan nama lengkap',
                        controller: _nameController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nama wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      NeoTextField(
                        label: 'Alamat Email',
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
                      NeoTextField(
                        label: 'Nomor Telepon / WhatsApp',
                        placeholder: '081234567890',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 200,
                        child: NeoButton(
                          text: 'Simpan Perubahan',
                          isLoading: _isSaving,
                          onPressed: _handleSaveProfile,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
