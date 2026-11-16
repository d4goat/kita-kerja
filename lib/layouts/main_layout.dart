import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/controllers/auth_controller.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/widgets/neo_components.dart';
import 'package:kita_kerja/widgets/smooth_scroll.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final String activeMenu; // 'dashboard', 'karyawan', 'kehadiran', 'pekerjaan', 'pengaturan'
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
        case 'pengaturan':
        case 'settings':
          Navigator.pushReplacementNamed(context, '/pengaturan');
          break;
        case 'logout':
          _showLogoutDialog(context);
          break;
      }
    }
  }

  void _showRoleSwitchDialog(BuildContext context, AuthController auth) {
    NeoDialog.show(
      context: context,
      title: 'Ganti Role Demo',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRoleOption(
            label: 'ADMIN / OWNER',
            desc: 'Akses penuh ke semua fitur dan Data Master',
            role: 'admin',
            currentRole: auth.currentUser?.role ?? 'admin',
            onTap: () {
              Navigator.pop(context);
              auth.loginAsRole('admin');
              Utils.toast(context, 'Beralih ke Admin (Hendra Wijaya)', ToastificationType.success, Icons.admin_panel_settings, Utils.neoGreen);
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
          const SizedBox(height: 12),
          _buildRoleOption(
            label: 'MANAGER / SUPERVISOR',
            desc: 'Akses monitoring tim, pekerjaan, dan kehadiran',
            role: 'manager',
            currentRole: auth.currentUser?.role ?? 'admin',
            onTap: () {
              Navigator.pop(context);
              auth.loginAsRole('manager');
              Utils.toast(context, 'Beralih ke Manager (Budi Santoso)', ToastificationType.success, Icons.supervisor_account, Utils.neoBlue);
              Navigator.pushReplacementNamed(context, '/pekerjaan');
            },
          ),
          const SizedBox(height: 12),
          _buildRoleOption(
            label: 'KARYAWAN PELAKSANA',
            desc: 'Akses presensi mandiri, tugas saya, & slip gaji',
            role: 'employee',
            currentRole: auth.currentUser?.role ?? 'admin',
            onTap: () {
              Navigator.pop(context);
              auth.loginAsRole('employee');
              Utils.toast(context, 'Beralih ke Karyawan (Citra Staff)', ToastificationType.success, Icons.badge, Utils.neoYellow);
              Navigator.pushReplacementNamed(context, '/kehadiran');
            },
          ),
        ],
      ),
      actions: [
        NeoButton(
          text: 'Tutup',
          variant: NeoButtonVariant.neutral,
          size: NeoButtonSize.sm,
          onPressed: () => Navigator.pop(context),
        ),
      ],
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? Utils.neoYellow : Utils.neoCream,
            borderRadius: BorderRadius.zero,
            border: Utils.borderW,
            boxShadow: isSelected ? Utils.shadowMd : Utils.shadowSm,
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Utils.neoBlack : Utils.neoCream,
                  border: Border.all(color: Utils.neoBlack, width: 2),
                ),
                alignment: Alignment.center,
                child: isSelected
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Utils.neoCream,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Utils.neoBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Utils.neoBlack,
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

  void _showLogoutDialog(BuildContext context) {
    NeoDialog.show(
      context: context,
      title: 'Keluar dari aplikasi?',
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Utils.neoYellow,
              borderRadius: BorderRadius.zero,
              border: Utils.borderW,
              boxShadow: Utils.shadowSm,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.warning_amber_rounded, color: Utils.neoBlack, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Sesi Anda akan diakhiri. Anda perlu login kembali untuk mengakses aplikasi.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Utils.neoBlack,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
      actions: [
        NeoButton(
          text: 'Batal',
          variant: NeoButtonVariant.neutral,
          size: NeoButtonSize.sm,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        NeoButton(
          text: 'Logout',
          variant: NeoButtonVariant.danger,
          size: NeoButtonSize.sm,
          onPressed: () {
            Navigator.pop(context);
            Provider.of<AuthController>(context, listen: false).logout();
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          },
        ),
      ],
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
      backgroundColor: Utils.neoCream,
      body: Row(
        children: [
          // 5.1 SIDEBAR (240px, fill Neo Cream, border-kanan 3px solid #111111)
          Container(
            width: 240,
            decoration: const BoxDecoration(
              color: Utils.neoCream,
              border: Border(right: Utils.borderSideW),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo KerjaKita: Black box with cream text (Space Grotesk 700 24px)
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    border: Border(bottom: Utils.borderSideW),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Utils.neoBlack,
                      borderRadius: BorderRadius.zero,
                      border: Utils.borderW,
                      boxShadow: Utils.shadowSm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'KERJAKITA',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Utils.neoCream,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Exactly 5 Menu Items (PRD 4 & 12):
                // Dashboard · Karyawan · Kehadiran · Pekerjaan · Pengaturan
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // 1. Dashboard
                      _SidebarMenuItem(
                        icon: Icons.dashboard,
                        label: isEmployee ? 'Dashboard Saya' : 'Dashboard',
                        isActive: widget.activeMenu == 'dashboard',
                        onTap: () => _navigateTo('dashboard'),
                      ),
                      const SizedBox(height: 8),

                      // 2. Karyawan
                      _SidebarMenuItem(
                        icon: Icons.people,
                        label: isEmployee ? 'Profil Saya' : (auth.isManager ? 'Karyawan Tim' : 'Karyawan'),
                        isActive: widget.activeMenu == 'karyawan',
                        onTap: () => _navigateTo('karyawan'),
                      ),
                      const SizedBox(height: 8),

                      // 3. Kehadiran
                      _SidebarMenuItem(
                        icon: Icons.calendar_today,
                        label: isEmployee ? 'Presensi Saya' : 'Kehadiran',
                        isActive: widget.activeMenu == 'kehadiran',
                        onTap: () => _navigateTo('kehadiran'),
                      ),
                      const SizedBox(height: 8),

                      // 4. Pekerjaan
                      _SidebarMenuItem(
                        icon: Icons.assignment,
                        label: isEmployee ? 'Tugas Saya' : 'Pekerjaan',
                        isActive: widget.activeMenu == 'pekerjaan',
                        onTap: () => _navigateTo('pekerjaan'),
                      ),
                      const SizedBox(height: 8),

                      // 5. Pengaturan
                      _SidebarMenuItem(
                        icon: Icons.settings,
                        label: 'Pengaturan',
                        isActive: widget.activeMenu == 'pengaturan' || widget.activeMenu == 'profile' || widget.activeMenu == 'master_data',
                        onTap: () => _navigateTo('pengaturan'),
                      ),
                    ],
                  ),
                ),

                // Footer System Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: Utils.borderSideW),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Utils.neoBlack,
                          borderRadius: BorderRadius.zero,
                          border: Utils.borderW,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'KK',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Utils.neoCream,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'KerjaKita UMKM',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Utils.neoBlack,
                            ),
                          ),
                          Text(
                            'v2.0 Neo-Brutalism',
                            style: GoogleFonts.inter(fontSize: 11, color: Utils.neoBlack),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 5.2 TOPBAR 72px: fill Neo Cream, border-bawah 3px solid #111111
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  decoration: const BoxDecoration(
                    color: Utils.neoCream,
                    border: Border(bottom: Utils.borderSideW),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Utils.neoBlack,
                        ),
                      ),
                      Row(
                        children: [
                          // Chip Role: fill Neo Black, text Neo Cream, label caps
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: const BoxDecoration(
                              color: Utils.neoBlack,
                              borderRadius: BorderRadius.zero,
                              border: Utils.borderW,
                            ),
                            child: Text(
                              userRole == 'ADMIN'
                                  ? 'ADMIN / OWNER'
                                  : (userRole == 'MANAGER' ? 'MANAGER' : 'KARYAWAN'),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Utils.neoCream,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // User Avatar Menu Dropdown (40x40 square yellow avatar)
                          PopupMenuButton<String>(
                            offset: const Offset(0, 48),
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: Utils.borderSideW,
                            ),
                            color: Utils.neoCream,
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
                                  children: [
                                    const Icon(Icons.person, color: Utils.neoBlack, size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Pengaturan & Profil',
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Utils.neoBlack),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(height: 2),
                              PopupMenuItem(
                                value: 'switch_role',
                                child: Row(
                                  children: [
                                    const Icon(Icons.swap_horiz, color: Utils.neoBlue, size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Ganti Role Demo',
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Utils.neoBlack),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(height: 2),
                              PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    const Icon(Icons.logout, color: Utils.neoRed, size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Keluar',
                                      style: GoogleFonts.inter(color: Utils.neoRed, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Row(
                                children: [
                                  NeoAvatar(name: userName, size: 40),
                                  const SizedBox(width: 10),
                                  Text(
                                    userName,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.neoBlack,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_drop_down, color: Utils.neoBlack),
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
}

class _SidebarMenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarMenuItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_SidebarMenuItem> createState() => _SidebarMenuItemState();
}

class _SidebarMenuItemState extends State<_SidebarMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // 5.1 Item styling rules:
    // Default: fill Neo Cream, text/icon Neo Black, no shadow
    // Hover: fill Neo Yellow, text/icon Neo Black, translate(-2, -2) + shadow md (4, 4)
    // Active: fill Neo Blue, text/icon Neo Cream, shadow md (4, 4)
    Color bg = Utils.neoCream;
    Color fg = Utils.neoBlack;
    double tx = 0;
    double ty = 0;
    List<BoxShadow> shadow = Utils.shadowNone;

    if (widget.isActive) {
      bg = Utils.neoBlue;
      fg = Utils.neoCream;
      shadow = Utils.shadowMd;
    } else if (_isHovered) {
      bg = Utils.neoYellow;
      fg = Utils.neoBlack;
      tx = -2;
      ty = -2;
      shadow = Utils.shadowMd;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          transform: Matrix4.translationValues(tx, ty, 0),
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.zero,
            border: Utils.borderW,
            boxShadow: shadow,
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: fg, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: fg,
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
