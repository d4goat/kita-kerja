import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/controllers/auth_controller.dart';
import 'package:kita_kerja/controllers/master_data_controller.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/widgets/neo_components.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class SettingsScreen extends StatefulWidget {
  final int initialTab;
  const SettingsScreen({super.key, this.initialTab = 0});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _mainTab; // 0: Profil, 1: Data Master, 2: Keamanan
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isSavingProfile = false;
  bool _isChangingPassword = false;

  final _masterTabs = [
    {
      'title': 'Jabatan',
      'table': 'positions',
      'desc': 'Digunakan untuk mengelompokkan peran karyawan',
    },
    {
      'title': 'Departemen',
      'table': 'departments',
      'desc': 'Mengelompokkan divisi atau departemen kerja',
    },
    {
      'title': 'Kategori Pekerjaan',
      'table': 'job_categories',
      'desc': 'Digunakan dalam penugasan & kategori pekerjaan',
    },
    {
      'title': 'Jenis Gaji',
      'table': 'salary_types',
      'desc': 'Acuan komponen dan sistem gaji/kompensasi',
    },
    {
      'title': 'Jadwal Kerja',
      'table': 'work_schedules',
      'desc': 'Acuan jam kerja, absensi, dan estimasi kapasitas',
    },
  ];

  @override
  void initState() {
    super.initState();
    _mainTab = widget.initialTab;
    final user = Provider.of<AuthController>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.name ?? 'Admin KerjaKita');
    _emailController = TextEditingController(text: user?.email ?? 'admin@kerjakita.local');
    _phoneController = TextEditingController(text: user?.phone ?? '081234567890');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mainTab == 1) {
        context.read<MasterDataController>().setSelectedTab(0);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleSaveProfile() async {
    if (_profileFormKey.currentState?.validate() ?? false) {
      setState(() => _isSavingProfile = true);
      final auth = Provider.of<AuthController>(context, listen: false);

      final ok = await auth.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isSavingProfile = false);

      if (ok) {
        Utils.toast(
          context,
          'Profil akun berhasil diperbarui!',
          ToastificationType.success,
          Icons.check,
          Utils.neoGreen,
        );
      } else {
        Utils.toast(
          context,
          'Gagal memperbarui profil, silakan coba lagi.',
          ToastificationType.error,
          Icons.close,
          Utils.neoRed,
        );
      }
    }
  }

  void _handleChangePassword() async {
    if (_passwordFormKey.currentState?.validate() ?? false) {
      if (_newPassController.text != _confirmPassController.text) {
        Utils.toast(
          context,
          'Konfirmasi kata sandi baru tidak cocok!',
          ToastificationType.warning,
          Icons.warning,
          Utils.neoYellow,
        );
        return;
      }

      setState(() => _isChangingPassword = true);
      final auth = Provider.of<AuthController>(context, listen: false);

      try {
        final ok = await auth.changePassword(
          oldPassword: _oldPassController.text,
          newPassword: _newPassController.text,
        );

        if (!mounted) return;
        setState(() => _isChangingPassword = false);

        if (ok) {
          _oldPassController.clear();
          _newPassController.clear();
          _confirmPassController.clear();
          Utils.toast(
            context,
            'Kata sandi berhasil diperbarui!',
            ToastificationType.success,
            Icons.check,
            Utils.neoGreen,
          );
        } else {
          Utils.toast(
            context,
            'Gagal mengubah kata sandi. Pastikan sandi lama benar.',
            ToastificationType.error,
            Icons.close,
            Utils.neoRed,
          );
        }
      } catch (err) {
        if (!mounted) return;
        setState(() => _isChangingPassword = false);
        Utils.toast(
          context,
          err.toString().replaceAll('Exception: ', ''),
          ToastificationType.error,
          Icons.close,
          Utils.neoRed,
        );
      }
    }
  }

  void _showMasterAddEditDialog({Map<String, dynamic>? editItem}) {
    final masterCtrl = context.read<MasterDataController>();
    final isEdit = editItem != null;
    final nameController = TextEditingController(
      text: isEdit ? editItem['name'].toString() : '',
    );
    final descController = TextEditingController(
      text: isEdit ? (editItem['description'] ?? '').toString() : '',
    );

    final startTimeController = TextEditingController(
      text: isEdit ? (editItem['start_time'] ?? '08:00:00') : '08:00:00',
    );
    final endTimeController = TextEditingController(
      text: isEdit ? (editItem['end_time'] ?? '17:00:00') : '17:00:00',
    );
    final breakMinutesController = TextEditingController(
      text: isEdit ? (editItem['break_minutes'] ?? 60).toString() : '60',
    );
    final workingHoursController = TextEditingController(
      text: isEdit ? (editItem['working_hours'] ?? 8.0).toString() : '8.0',
    );

    String status = isEdit ? (editItem['status'] ?? 'active').toString() : 'active';
    final tabTitle = _masterTabs[masterCtrl.selectedTabIndex]['title'];

    NeoDialog.show(
      context: context,
      title: isEdit ? 'Ubah Data $tabTitle' : 'Tambah Data $tabTitle',
      maxWidth: 480,
      content: StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeoTextField(
                label: 'Nama $tabTitle',
                placeholder: 'Masukkan nama...',
                controller: nameController,
              ),
              const SizedBox(height: 14),
              if (masterCtrl.selectedTabIndex != 4) ...[
                NeoTextField(
                  label: 'Deskripsi / Keterangan',
                  placeholder: 'Masukkan deskripsi...',
                  controller: descController,
                  maxLines: 2,
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: NeoTextField(
                        label: 'Jam Mulai',
                        placeholder: '08:00:00',
                        controller: startTimeController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeoTextField(
                        label: 'Jam Selesai',
                        placeholder: '17:00:00',
                        controller: endTimeController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: NeoTextField(
                        label: 'Istirahat (Menit)',
                        placeholder: '60',
                        controller: breakMinutesController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeoTextField(
                        label: 'Jam Kerja (Otomatis)',
                        placeholder: '8.0',
                        controller: workingHoursController,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
              ],
              if (isEdit) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'STATUS DATA:',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Utils.neoBlack,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 14),
                    NeoToggleSwitch(
                      value: status == 'active',
                      onChanged: (val) {
                        setDialogState(() {
                          status = val ? 'active' : 'inactive';
                        });
                      },
                    ),
                  ],
                ),
              ],
            ],
          );
        },
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
          text: 'Simpan',
          variant: NeoButtonVariant.primary,
          size: NeoButtonSize.sm,
          onPressed: () async {
            final name = nameController.text.trim();
            if (name.isEmpty) {
              Utils.toast(context, 'Nama $tabTitle tidak boleh kosong', ToastificationType.warning, Icons.warning, Utils.neoYellow);
              return;
            }
            Navigator.pop(context);

            bool ok = false;
            if (isEdit) {
              final id = int.tryParse(editItem['id'].toString()) ?? 0;
              if (masterCtrl.selectedTabIndex == 4) {
                ok = await masterCtrl.updateWorkSchedule(
                  id: id,
                  name: name,
                  startTime: startTimeController.text.trim(),
                  endTime: endTimeController.text.trim(),
                  breakMinutes: int.tryParse(breakMinutesController.text) ?? 60,
                  workingHours: double.tryParse(workingHoursController.text) ?? 8.0,
                  status: status,
                );
              } else {
                ok = await masterCtrl.updateItem(id: id, name: name, description: descController.text.trim(), status: status);
              }
            } else {
              if (masterCtrl.selectedTabIndex == 4) {
                ok = await masterCtrl.addWorkSchedule(
                  name: name,
                  startTime: startTimeController.text.trim(),
                  endTime: endTimeController.text.trim(),
                  breakMinutes: int.tryParse(breakMinutesController.text) ?? 60,
                  workingHours: double.tryParse(workingHoursController.text) ?? 8.0,
                );
              } else {
                ok = await masterCtrl.addItem(name: name, description: descController.text.trim());
              }
            }

            if (!mounted) return;
            if (ok) {
              Utils.toast(context, 'Data $tabTitle berhasil disimpan!', ToastificationType.success, Icons.check, Utils.neoGreen);
            } else {
              Utils.toast(context, 'Gagal menyimpan data', ToastificationType.error, Icons.close, Utils.neoRed);
            }
          },
        ),
      ],
    );
  }

  Widget _buildProfileTab(dynamic user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 8.7 Profil Kiri (4/12): Avatar lg 96 + nama + Chip Role
        Expanded(
          flex: 4,
          child: NeoContainer(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NeoAvatar(name: user?.name ?? 'User', size: 96),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'User',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Utils.neoBlack,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user?.email ?? '',
                  style: GoogleFonts.inter(fontSize: 13, color: Utils.neoBlack),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Utils.neoBlack,
                    borderRadius: BorderRadius.zero,
                    border: Utils.borderW,
                  ),
                  child: Text(
                    (user?.role ?? 'ADMIN').toString().toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Utils.neoCream,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),

        // Profil Kanan (8/12): Form Profil
        Expanded(
          flex: 8,
          child: NeoContainer(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _profileFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INFORMASI AKUN',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Utils.neoBlack,
                    ),
                  ),
                  const SizedBox(height: 20),
                  NeoTextField(
                    label: 'Nama Lengkap',
                    placeholder: 'Masukkan nama lengkap',
                    controller: _nameController,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  NeoTextField(
                    label: 'Alamat Email',
                    placeholder: 'nama@perusahaan.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Email wajib diisi';
                      if (!val.contains('@')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  NeoTextField(
                    label: 'Nomor Telepon',
                    placeholder: '081234567890',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: NeoButton(
                      text: 'SIMPAN PROFIL',
                      variant: NeoButtonVariant.primary,
                      isLoading: _isSavingProfile,
                      onPressed: _handleSaveProfile,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityTab() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        child: NeoContainer(
          padding: const EdgeInsets.all(28),
          child: Form(
          key: _passwordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UBAH KATA SANDI',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Utils.neoBlack,
                ),
              ),
              const SizedBox(height: 20),
              NeoTextField(
                label: 'Kata Sandi Saat Ini',
                placeholder: 'Masukkan kata sandi lama',
                controller: _oldPassController,
                isPassword: true,
                validator: (val) => val == null || val.isEmpty ? 'Kata sandi lama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              NeoTextField(
                label: 'Kata Sandi Baru',
                placeholder: 'Minimal 8 karakter',
                controller: _newPassController,
                isPassword: true,
                validator: (val) => val == null || val.length < 8 ? 'Kata sandi minimal 8 karakter' : null,
              ),
              const SizedBox(height: 16),
              NeoTextField(
                label: 'Konfirmasi Kata Sandi Baru',
                placeholder: 'Ulangi kata sandi baru',
                controller: _confirmPassController,
                isPassword: true,
                validator: (val) => val == null || val.isEmpty ? 'Konfirmasi kata sandi wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: NeoButton(
                  text: 'UBAH KATA SANDI',
                  variant: NeoButtonVariant.primary,
                  isLoading: _isChangingPassword,
                  onPressed: _handleChangePassword,
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMasterDataTab(MasterDataController masterCtrl, bool isAdmin) {
    final subTabs = _masterTabs.map((t) => t['title'] as String).toList();
    final items = masterCtrl.currentItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-Tabs Data Master
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NeoTabs(
              tabs: subTabs,
              selectedIndex: masterCtrl.selectedTabIndex,
              onTabSelected: (idx) => masterCtrl.setSelectedTab(idx),
            ),
            if (isAdmin)
              NeoButton(
                text: '+ Tambah Data',
                variant: NeoButtonVariant.primary,
                onPressed: () => _showMasterAddEditDialog(),
              ),
          ],
        ),
        const SizedBox(height: 24),

        // Single-Frame Table Data Master
        NeoTable(
          isLoading: masterCtrl.isLoading,
          emptyIcon: Icons.layers_outlined,
          emptyText: 'Belum ada data untuk kategori ini',
          columnWidths: const {
            0: FlexColumnWidth(2.2),
            1: FlexColumnWidth(3.0),
            2: FlexColumnWidth(1.2),
            3: FlexColumnWidth(1.2),
            4: FlexColumnWidth(1.2),
          },
          headers: const [
            NeoTableHeaderCell('NAMA'),
            NeoTableHeaderCell('DESKRIPSI / JAM KERJA'),
            NeoTableHeaderCell('DIPAKAI'),
            NeoTableHeaderCell('STATUS'),
            NeoTableHeaderCell('AKSI', alignment: Alignment.center),
          ],
          rows: items.map((item) {
            final isSchedule = masterCtrl.selectedTabIndex == 4;
            final desc = isSchedule
                ? '${item['start_time']} – ${item['end_time']} (${item['working_hours']}j)'
                : (item['description'] ?? '-').toString();
            final statusStr = (item['status'] ?? 'active').toString();

            return [
              NeoTableCell(text: item['name'].toString(), isBold: true),
              NeoTableCell(text: desc),
              NeoTableCell(text: '${item['used_count'] ?? 0} Karyawan'),
              NeoTableCell(
                child: NeoToggleSwitch(
                  value: statusStr == 'active',
                  readOnly: !isAdmin,
                  onChanged: (val) async {
                    final id = int.tryParse(item['id'].toString()) ?? 0;
                    await masterCtrl.toggleStatus(id, val ? 'active' : 'inactive');
                  },
                ),
              ),
              NeoTableCell(
                alignment: Alignment.center,
                child: isAdmin
                    ? NeoIconButton(
                        icon: Icons.edit,
                        size: 32,
                        tooltip: 'Ubah',
                        onPressed: () => _showMasterAddEditDialog(editItem: item),
                      )
                    : const Text('-'),
              ),
            ];
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final user = auth.currentUser;
    final isAdmin = auth.isAdmin;
    final isManager = auth.isManager;
    final canAccessMaster = isAdmin || isManager;

    final tabs = [
      'PROFIL',
      if (canAccessMaster) 'DATA MASTER',
      'KEAMANAN',
    ];

    return Consumer<MasterDataController>(
      builder: (context, masterCtrl, child) {
        return MainLayout(
          title: 'Pengaturan',
          activeMenu: 'pengaturan',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Level Tabs: Profil · Data Master · Keamanan (Section 8.7)
                  NeoTabs(
                    tabs: tabs,
                    selectedIndex: _mainTab.clamp(0, tabs.length - 1),
                    onTabSelected: (idx) {
                      setState(() {
                        if (!canAccessMaster && idx == 1) {
                          _mainTab = 2; // Jump to Keamanan
                        } else {
                          _mainTab = idx;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Content
                  if (_mainTab == 0)
                    _buildProfileTab(user)
                  else if (_mainTab == 1 && canAccessMaster)
                    _buildMasterDataTab(masterCtrl, isAdmin)
                  else
                    _buildSecurityTab(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
