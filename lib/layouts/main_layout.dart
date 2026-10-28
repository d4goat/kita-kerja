import 'package:flutter/material.dart';
import 'package:kita_kerja/controllers/auth_controller.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/widgets/smooth_scroll.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final String activeMenu; // 'dashboard', 'karyawan', 'kehadiran', 'pekerjaan', 'master_data', 'profile', 'gaji'
  final Function(String menu)? onMenuSelected;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    this.activeMenu = 'dashboard',
    this.onMenuSelected,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  void _navigateTo(String menu) {
    if (widget.onMenuSelected != null) {
      widget.onMenuSelected!(menu);
    } else {
      switch (menu) {
        case 'dashboard':
          Navigator.pushReplacementNamed(context, '/dashboard');
          break;
        case 'karyawan':
          Navigator.pushReplacementNamed(context, '/karyawan');
          break;
        case 'kehadiran':
          Navigator.pushReplacementNamed(context, '/kehadiran');
          break;
        case 'pekerjaan':
          Navigator.pushReplacementNamed(context, '/pekerjaan');
          break;
        case 'master_data':
          Navigator.pushReplacementNamed(context, '/master-data');
          break;
        case 'profile':
          Navigator.pushReplacementNamed(context, '/profile');
          break;
        case 'logout':
          _showLogoutDialog(context);
          break;
      }
    }
  }

  void _showRoleSwitchDialog(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Utils.border, width: 2),
          ),
          title: const Text(
            'Ganti Role (Demo Mode)',
            style: TextStyle(fontWeight: FontWeight.w800, color: Utils.border),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRoleOption(
                label: 'Admin / Owner',
                desc: 'Akses penuh ke semua fitur dan Data Master',
                role: 'admin',
                currentRole: auth.currentUser?.role ?? 'admin',
                onTap: () {
                  Navigator.pop(dialogContext);
                  auth.loginAsRole('admin');
                  Utils.toast(context, 'Beralih ke Admin (Hendra Wijaya)', ToastificationType.success, Icons.admin_panel_settings, Utils.success);
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
              ),
              const SizedBox(height: 10),
              _buildRoleOption(
                label: 'Manager / Supervisor',
                desc: 'Akses monitoring tim, pekerjaan, dan kehadiran',
                role: 'manager',
                currentRole: auth.currentUser?.role ?? 'admin',
                onTap: () {
                  Navigator.pop(dialogContext);
                  auth.loginAsRole('manager');
                  Utils.toast(context, 'Beralih ke Manager (Budi Santoso)', ToastificationType.success, Icons.supervisor_account, Utils.primary);
                  Navigator.pushReplacementNamed(context, '/pekerjaan');
                },
              ),
              const SizedBox(height: 10),
              _buildRoleOption(
                label: 'Karyawan (Employee)',
                desc: 'Akses presensi mandiri, tugas saya, & slip gaji',
                role: 'employee',
                currentRole: auth.currentUser?.role ?? 'admin',
                onTap: () {
                  Navigator.pop(dialogContext);
                  auth.loginAsRole('employee');
                  Utils.toast(context, 'Beralih ke Karyawan (Citra Staff)', ToastificationType.success, Icons.badge, Utils.secondary);
                  Navigator.pushReplacementNamed(context, '/kehadiran');
                },
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Utils.border, width: 2),
              ),
              child: const Text('Tutup', style: TextStyle(color: Utils.border)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRoleOption({
    required String label,
    required String desc,
    required String role,
    required String currentRole,
    required VoidCallback onTap,
  }) {
    final isSelected = currentRole.toLowerCase() == role.toLowerCase();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F1E8) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Utils.primary : const Color(0xFFE0E0E0), width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Utils.primary : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Utils.border)),
                  Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
                style: TextStyle(fontWeight: FontWeight.bold, color: Utils.border),
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
                Provider.of<AuthController>(context, listen: false).logout();
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
    Utils().init(context);
    final auth = Provider.of<AuthController>(context);
    final currentUser = auth.currentUser;
    final userName = currentUser?.name ?? 'User';
    final userRole = (currentUser?.role ?? 'ADMIN').toUpperCase();
    final isEmployee = auth.isEmployee;

    return Scaffold(
      backgroundColor: Utils.background,
      body: Row(
        children: [
          // SIDEBAR
          Container(
            width: 240,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Utils.border, width: 2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header Section
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Utils.border, width: 2)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 35,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: const [
                              BoxShadow(color: Utils.border, offset: Offset(2, 2), blurRadius: 0),
                            ],
                          ),
                          child: ClipRRect(
                            child: Image.asset('assets/img/icon-v2.png'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'KerjaKita',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Utils.border,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Navigation Items according to Role
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    children: [
                      // 1. Dashboard
                      _buildSidebarItem(
                        icon: Icons.grid_view_rounded,
                        label: isEmployee ? 'Dashboard Saya' : 'Dashboard',
                        isActive: widget.activeMenu == 'dashboard',
                        onTap: () => _navigateTo('dashboard'),
                      ),
                      const SizedBox(height: 8),

                      // 2. Karyawan (only Admin & Manager)
                      if (!isEmployee) ...[
                        _buildSidebarItem(
                          icon: Icons.people_outline,
                          label: auth.isManager ? 'Karyawan Tim' : 'Karyawan',
                          isActive: widget.activeMenu == 'karyawan',
                          onTap: () => _navigateTo('karyawan'),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // 3. Kehadiran
                      _buildSidebarItem(
                        icon: Icons.access_time_rounded,
                        label: isEmployee ? 'Presensi Saya' : 'Kehadiran',
                        isActive: widget.activeMenu == 'kehadiran',
                        onTap: () => _navigateTo('kehadiran'),
                      ),
                      const SizedBox(height: 8),

                      // 4. Pekerjaan
                      _buildSidebarItem(
                        icon: Icons.assignment_outlined,
                        label: isEmployee ? 'Tugas Saya' : 'Pekerjaan',
                        isActive: widget.activeMenu == 'pekerjaan',
                        onTap: () => _navigateTo('pekerjaan'),
                      ),
                      const SizedBox(height: 8),

                      // 5. Slip Gaji (Khusus Karyawan)
                      if (isEmployee) ...[
                        _buildSidebarItem(
                          icon: Icons.receipt_long_outlined,
                          label: 'Slip Gaji Saya',
                          isActive: widget.activeMenu == 'karyawan' || widget.activeMenu == 'gaji',
                          onTap: () => _navigateTo('karyawan'),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // 6. Data Master (Only Admin / Owner)
                      if (auth.isAdmin) ...[
                        _buildSidebarItem(
                          icon: Icons.settings_outlined,
                          label: 'Data Master',
                          isActive: widget.activeMenu == 'master_data',
                          onTap: () => _navigateTo('master_data'),
                        ),
                      ],
                    ],
                  ),
                ),

                // Footer System Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Utils.border, width: 2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Utils.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Utils.border, width: 2),
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'HR System',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Utils.border,
                            ),
                          ),
                          Text(
                            'v1.2 Clean MVC',
                            style: TextStyle(fontSize: 11, color: Color(0xFF666666)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Utils.border, width: 2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Utils.border,
                        ),
                      ),
                      Row(
                        children: [
                          // Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isEmployee ? Utils.secondary : (auth.isManager ? const Color(0xFFE5F0FF) : Colors.white),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Utils.border, width: 2),
                              boxShadow: const [
                                BoxShadow(color: Utils.border, offset: Offset(2, 2), blurRadius: 0),
                              ],
                            ),
                            child: Text(
                              userRole,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Utils.border,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // User Avatar Menu Dropdown
                          PopupMenuButton<String>(
                            offset: const Offset(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Utils.border, width: 2),
                            ),
                            color: Colors.white,
                            onSelected: (val) {
                              if (val == 'profile') {
                                _navigateTo('profile');
                              } else if (val == 'switch_role') {
                                _showRoleSwitchDialog(context, auth);
                              } else if (val == 'logout') {
                                _showLogoutDialog(context);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'profile',
                                child: Row(
                                  children: const [
                                    Icon(Icons.person_outline, color: Utils.border, size: 20),
                                    SizedBox(width: 10),
                                    Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'switch_role',
                                child: Row(
                                  children: const [
                                    Icon(Icons.swap_horiz, color: Utils.primary, size: 20),
                                    SizedBox(width: 10),
                                    Text('Ganti Role Demo', style: TextStyle(fontWeight: FontWeight.w600, color: Utils.primary)),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: const [
                                    Icon(Icons.logout, color: Utils.danger, size: 20),
                                    SizedBox(width: 10),
                                    Text('Keluar', style: TextStyle(color: Utils.danger, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ],
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Utils.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Utils.border, width: 2),
                                    ),
                                    child: const Icon(Icons.person, color: Colors.white, size: 22),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.border,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_drop_down, color: Utils.border),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Page Body Content
                Expanded(child: SmoothScrollWrapper(child: widget.child)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Utils.secondary : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Utils.border, width: 2),
            boxShadow: isActive
                ? const [
                    BoxShadow(color: Utils.border, offset: Offset(2, 2), blurRadius: 0),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: Utils.border, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Utils.border,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
