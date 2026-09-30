import 'package:flutter/material.dart';
import 'package:kita_kerja/lib/utils.dart';
import 'package:kita_kerja/models/auth-model.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final String activeMenu; // 'dashboard', 'karyawan', 'kehadiran', 'pekerjaan', 'pengaturan', 'master_data', 'profile'
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
  bool _isPengaturanExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.activeMenu == 'master_data' ||
        widget.activeMenu == 'profile' ||
        widget.activeMenu == 'keamanan') {
      _isPengaturanExpanded = true;
    }
  }

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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Utils.border,
                ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Batal', style: TextStyle(color: Utils.border)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Provider.of<AuthModel>(context, listen: false).logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
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
    final auth = Provider.of<AuthModel>(context);
    final currentUser = auth.currentUser;
    final userName = currentUser?.name ?? 'Hendra Wijaya';
    final userRole = currentUser?.role.toUpperCase() ?? 'ADMIN';

    return Scaffold(
      backgroundColor: Utils.background,
      body: Row(
        children: [
          // SIDEBAR (Match exact styling in image.png)
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
                    border: Border(
                      bottom: BorderSide(color: Utils.border, width: 2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Utils.primary,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Utils.border, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'K',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
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
                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    children: [
                      _buildSidebarItem(
                        icon: Icons.grid_view_rounded,
                        label: 'Dashboard',
                        isActive: widget.activeMenu == 'dashboard',
                        onTap: () => _navigateTo('dashboard'),
                      ),
                      const SizedBox(height: 8),
                      _buildSidebarItem(
                        icon: Icons.people_outline,
                        label: 'Karyawan',
                        isActive: widget.activeMenu == 'karyawan',
                        onTap: () => _navigateTo('karyawan'),
                      ),
                      const SizedBox(height: 8),
                      _buildSidebarItem(
                        icon: Icons.access_time_rounded,
                        label: 'Kehadiran',
                        isActive: widget.activeMenu == 'kehadiran',
                        onTap: () => _navigateTo('kehadiran'),
                      ),
                      const SizedBox(height: 8),
                      _buildSidebarItem(
                        icon: Icons.assignment_outlined,
                        label: 'Pekerjaan',
                        isActive: widget.activeMenu == 'pekerjaan',
                        onTap: () => _navigateTo('pekerjaan'),
                      ),
                      const SizedBox(height: 8),
                      _buildSidebarItem(
                        icon: Icons.settings_outlined,
                        label: 'Pengaturan',
                        isActive:
                            widget.activeMenu == 'pengaturan' ||
                            widget.activeMenu == 'master_data' ||
                            widget.activeMenu == 'profile',
                        hasSubMenu: true,
                        isExpanded: _isPengaturanExpanded,
                        onTap: () {
                          setState(() {
                            _isPengaturanExpanded = !_isPengaturanExpanded;
                          });
                        },
                      ),
                      if (_isPengaturanExpanded) ...[
                        const SizedBox(height: 6),
                        _buildSubMenuItem(
                          icon: Icons.person_outline,
                          label: 'Profil',
                          isActive: widget.activeMenu == 'profile',
                          onTap: () => _navigateTo('profile'),
                        ),
                        if (userRole == 'ADMIN' || userRole == 'OWNER') ...[
                          const SizedBox(height: 4),
                          _buildSubMenuItem(
                            icon: Icons.dataset_outlined,
                            label: 'Data Master',
                            isActive: widget.activeMenu == 'master_data',
                            onTap: () => _navigateTo('master_data'),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                // Footer System Info (as seen in bottom left of image.png)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Utils.border, width: 2),
                    ),
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
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 18,
                        ),
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
                            'v1.1 Neo',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF666666),
                            ),
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
                    border: Border(
                      bottom: BorderSide(color: Utils.border, width: 2),
                    ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Utils.border, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Utils.border,
                                  offset: Offset(2, 2),
                                  blurRadius: 0,
                                ),
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
                              side: const BorderSide(
                                color: Utils.border,
                                width: 2,
                              ),
                            ),
                            color: Colors.white,
                            onSelected: (val) {
                              if (val == 'profile') {
                                _navigateTo('profile');
                              } else if (val == 'master_data') {
                                _navigateTo('master_data');
                              } else if (val == 'logout') {
                                _showLogoutDialog(context);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'profile',
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.person_outline,
                                      color: Utils.border,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Profil Saya',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (userRole == 'ADMIN' || userRole == 'OWNER')
                                PopupMenuItem(
                                  value: 'master_data',
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.dataset_outlined,
                                        color: Utils.border,
                                        size: 20,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Data Master',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.logout,
                                      color: Utils.danger,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Keluar',
                                      style: TextStyle(
                                        color: Utils.danger,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
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
                                      border: Border.all(
                                        color: Utils.border,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 22,
                                    ),
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
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: Utils.border,
                                  ),
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
                Expanded(child: widget.child),
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
    bool hasSubMenu = false,
    bool isExpanded = false,
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
                    BoxShadow(
                      color: Utils.border,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
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
              if (hasSubMenu)
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Utils.border,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubMenuItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? Utils.secondary.withAlpha(100)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: isActive
                  ? Border.all(color: Utils.border, width: 2)
                  : null,
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Utils.border),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    color: Utils.border,
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
