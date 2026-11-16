import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/controllers/auth_controller.dart';
import 'package:kita_kerja/controllers/employee_controller.dart';
import 'package:kita_kerja/controllers/salary_controller.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/models/employee_model.dart';
import 'package:kita_kerja/models/master_data_model.dart';
import 'package:kita_kerja/models/salary_model.dart';
import 'package:kita_kerja/repositories/master_data_repository.dart';
import 'package:kita_kerja/widgets/neo_components.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class KaryawanScreen extends StatefulWidget {
  const KaryawanScreen({super.key});

  @override
  State<KaryawanScreen> createState() => _KaryawanScreenState();
}

class _KaryawanScreenState extends State<KaryawanScreen> {
  final MasterDataRepository _masterRepo = MasterDataRepository();
  int _currentTab = 0; // 0: Daftar Karyawan, 1: Rekap Gaji
  List<DepartmentModel> _departments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthController>(context, listen: false);
      Provider.of<EmployeeController>(context, listen: false).loadEmployees(currentUser: auth.currentUser);
      Provider.of<SalaryController>(context, listen: false).loadSalaries(auth.currentUser);
      _loadDepartments();
    });
  }

  Future<void> _loadDepartments() async {
    final depts = await _masterRepo.getDepartments();
    if (mounted) {
      setState(() => _departments = depts);
    }
  }

  void _handleToggleStatus(EmployeeModel item, EmployeeController controller) {
    final currentStatus = item.status;
    final actionLabel = currentStatus == 'active' ? 'Nonaktifkan' : 'Aktifkan';

    NeoDialog.show(
      context: context,
      title: '$actionLabel Karyawan?',
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Utils.neoYellow,
              border: Utils.borderW,
              boxShadow: Utils.shadowSm,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.warning_amber_rounded, color: Utils.neoBlack, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '"${item.fullName}" (${item.employeeCode}) ${currentStatus == 'active' ? 'tidak dapat menerima pekerjaan baru dan akunnya tidak dapat login. Data riwayat tetap tersimpan.' : 'akan diaktifkan kembali.'}',
              style: GoogleFonts.inter(fontSize: 14, color: Utils.neoBlack, height: 1.4),
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
          text: actionLabel,
          variant: currentStatus == 'active' ? NeoButtonVariant.danger : NeoButtonVariant.success,
          size: NeoButtonSize.sm,
          onPressed: () async {
            Navigator.pop(context);
            final ok = await controller.toggleEmployeeStatus(item.id, currentStatus);
            if (ok && mounted) {
              Utils.toast(
                context,
                'Karyawan "${item.fullName}" berhasil di-$actionLabel!',
                ToastificationType.success,
                Icons.check,
                Utils.neoGreen,
              );
            }
          },
        ),
      ],
    );
  }

  void _showEmployeeDetailDialog(EmployeeModel emp, EmployeeController empCtrl) {
    NeoDialog.show(
      context: context,
      title: 'Detail Karyawan',
      maxWidth: 520,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NeoAvatar(name: emp.fullName, size: 56),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emp.fullName,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Utils.neoBlack,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        NeoTag(label: emp.employeeCode),
                        const SizedBox(width: 8),
                        NeoBadge.account(emp.status),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Utils.neoBlack, thickness: 2, height: 2),
          const SizedBox(height: 16),
          _buildDetailItem('JABATAN', emp.positionName),
          _buildDetailItem('DEPARTEMEN', emp.departmentName),
          _buildDetailItem('SUPERVISOR TIM', emp.supervisorName != null && emp.supervisorName!.isNotEmpty ? emp.supervisorName! : 'Tidak Ada / Mandiri'),
          _buildDetailItem('EMAIL', emp.email.isNotEmpty ? emp.email : '-'),
          _buildDetailItem('TELEPON', emp.phone.isNotEmpty ? emp.phone : '-'),
          _buildDetailItem('JADWAL KERJA', emp.workScheduleName),
          _buildDetailItem('KOMPENSASI', emp.salaryTypeName),
          _buildDetailItem('TANGGAL GABUNG', emp.joinDate),
        ],
      ),
      actions: [
        NeoButton(
          text: 'Tutup',
          variant: NeoButtonVariant.neutral,
          size: NeoButtonSize.sm,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        NeoButton(
          text: 'Ubah Data',
          variant: NeoButtonVariant.secondary,
          size: NeoButtonSize.sm,
          onPressed: () async {
            Navigator.pop(context);
            final res = await Navigator.pushNamed(context, '/karyawan-form', arguments: emp.toMap());
            if (res == true && mounted) {
              empCtrl.loadEmployees();
            }
          },
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Utils.neoBlack,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Utils.neoBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section 7.7 Kartu Slip Gaji
  void _showSalaryDetailsDialog(SalaryModel sal) {
    NeoDialog.show(
      context: context,
      title: 'Slip Gaji Karyawan',
      maxWidth: 480,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getMonthName(sal.periodMonth)} ${sal.periodYear}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Utils.neoBlack,
                ),
              ),
              NeoBadge.salary(sal.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${sal.employeeName} (${sal.employeeCode}) • ${sal.departmentName}',
            style: GoogleFonts.inter(fontSize: 12, color: Utils.neoBlack),
          ),
          const SizedBox(height: 16),

          // Slip Gaji Rows
          Container(
            decoration: const BoxDecoration(
              color: Utils.neoCream,
              border: Utils.borderW,
              boxShadow: Utils.shadowSm,
            ),
            child: Column(
              children: [
                _buildReceiptRow('Gaji Pokok', Utils.formatRupiah(sal.basicSalary)),
                const Divider(height: 1, thickness: 2, color: Utils.neoBlack),
                _buildReceiptRow('Lembur', Utils.formatRupiah(sal.overtimeAmount)),
                const Divider(height: 1, thickness: 2, color: Utils.neoBlack),
                _buildReceiptRow('Bonus', Utils.formatRupiah(sal.bonusAmount)),
                const Divider(height: 1, thickness: 2, color: Utils.neoBlack),
                _buildReceiptRow('Potongan', '− ${Utils.formatRupiah(sal.deductionAmount)}'),
                const Divider(height: 1, thickness: 2, color: Utils.neoBlack),

                // GAJI BERSIH: Black block with cream text
                Container(
                  color: Utils.neoBlack,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GAJI BERSIH',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Utils.neoCream,
                        ),
                      ),
                      Text(
                        Utils.formatRupiah(sal.netSalary),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Utils.neoCream,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Utils.neoBlack,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Utils.neoBlack,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const names = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return (month >= 1 && month <= 12) ? names[month] : '$month';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final isEmployee = auth.isEmployee;

    return Consumer2<EmployeeController, SalaryController>(
      builder: (context, empCtrl, salCtrl, child) {
        final employees = empCtrl.employees;
        final salaries = isEmployee ? salCtrl.mySalaries : salCtrl.salaries;

        return MainLayout(
          title: isEmployee ? 'Profil & Gaji Saya' : 'Manajemen Karyawan',
          activeMenu: 'karyawan',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Top Level Tabs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NeoTabs(
                      tabs: isEmployee
                          ? const ['PROFIL SAYA', 'SLIP GAJI']
                          : const ['DAFTAR KARYAWAN', 'REKAP GAJI'],
                      selectedIndex: _currentTab,
                      onTabSelected: (idx) => setState(() => _currentTab = idx),
                    ),
                    if (auth.isAdmin && _currentTab == 0)
                      NeoButton(
                        text: '+ Tambah Karyawan',
                        variant: NeoButtonVariant.primary,
                        onPressed: () async {
                          final res = await Navigator.pushNamed(context, '/karyawan-form');
                          if (res == true && mounted) {
                            empCtrl.loadEmployees();
                          }
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                if (_currentTab == 0 && !isEmployee) ...[
                  // Toolbar: Search & Dept Filter
                  Row(
                    children: [
                      // Search Input
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Utils.neoCream,
                            borderRadius: BorderRadius.zero,
                            border: Utils.borderW,
                            boxShadow: Utils.shadowSm,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Utils.neoBlack, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  onChanged: (val) {
                                    empCtrl.setSearchQuery(val);
                                    empCtrl.loadEmployees();
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Cari nama, NIK, atau jabatan karyawan...',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    isDense: true,
                                  ),
                                  style: GoogleFonts.inter(fontSize: 14, color: Utils.neoBlack),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Department Dropdown
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: const BoxDecoration(
                          color: Utils.neoCream,
                          borderRadius: BorderRadius.zero,
                          border: Utils.borderW,
                          boxShadow: Utils.shadowSm,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: empCtrl.selectedDepartmentId,
                            dropdownColor: Utils.neoCream,
                            icon: const Icon(Icons.arrow_drop_down, color: Utils.neoBlack),
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Utils.neoBlack),
                            items: [
                              const DropdownMenuItem(value: 0, child: Text('Semua Departemen')),
                              ..._departments.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                empCtrl.setSelectedDepartmentId(val);
                                empCtrl.loadEmployees();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Karyawan Table
                  NeoTable(
                    isLoading: empCtrl.isLoading,
                    emptyIcon: Icons.people_outline,
                    emptyText: 'Tidak ada data karyawan ditemukan',
                    columnWidths: const {
                      0: FlexColumnWidth(2.2),
                      1: FlexColumnWidth(1.4),
                      2: FlexColumnWidth(1.4),
                      3: FlexColumnWidth(1.4),
                      4: FlexColumnWidth(1.2),
                      5: FlexColumnWidth(1.2),
                      6: FlexColumnWidth(1.4),
                    },
                    headers: const [
                      NeoTableHeaderCell('KARYAWAN'),
                      NeoTableHeaderCell('JABATAN'),
                      NeoTableHeaderCell('DEPARTEMEN'),
                      NeoTableHeaderCell('JADWAL KERJA'),
                      NeoTableHeaderCell('BERGABUNG'),
                      NeoTableHeaderCell('STATUS'),
                      NeoTableHeaderCell('AKSI', alignment: Alignment.center),
                    ],
                    rows: employees.map((emp) {
                      return [
                        NeoTableCell(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              NeoAvatar(name: emp.fullName, size: 32),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      emp.fullName,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Utils.neoBlack,
                                      ),
                                    ),
                                    Text(
                                      emp.supervisorName != null && emp.supervisorName!.isNotEmpty
                                          ? '${emp.employeeCode} • Spv: ${emp.supervisorName}'
                                          : emp.employeeCode,
                                      style: GoogleFonts.inter(fontSize: 11, color: Utils.neoBlack),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        NeoTableCell(child: NeoTag(label: emp.positionName)),
                        NeoTableCell(child: NeoTag(label: emp.departmentName)),
                        NeoTableCell(text: emp.workScheduleName),
                        NeoTableCell(text: emp.joinDate),
                        NeoTableCell(child: NeoBadge.account(emp.status)),
                        NeoTableCell(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              NeoIconButton(
                                icon: Icons.visibility,
                                size: 32,
                                tooltip: 'Lihat Detail',
                                onPressed: () => _showEmployeeDetailDialog(emp, empCtrl),
                              ),
                              if (auth.isAdmin) ...[
                                const SizedBox(width: 6),
                                NeoIconButton(
                                  icon: Icons.edit,
                                  size: 32,
                                  tooltip: 'Ubah Data',
                                  onPressed: () async {
                                    final res = await Navigator.pushNamed(context, '/karyawan-form', arguments: emp.toMap());
                                    if (res == true && mounted) {
                                      empCtrl.loadEmployees();
                                    }
                                  },
                                ),
                                const SizedBox(width: 6),
                                NeoIconButton(
                                  icon: emp.isActive ? Icons.block : Icons.check,
                                  size: 32,
                                  iconColor: emp.isActive ? Utils.neoRed : Utils.neoGreen,
                                  tooltip: emp.isActive ? 'Nonaktifkan' : 'Aktifkan',
                                  onPressed: () => _handleToggleStatus(emp, empCtrl),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ];
                    }).toList(),
                  ),
                ] else ...[
                  // Mode REKAP GAJI / SLIP GAJI
                  NeoTable(
                    isLoading: salCtrl.isLoading,
                    emptyIcon: Icons.receipt_long,
                    emptyText: 'Tidak ada data slip gaji',
                    columnWidths: isEmployee
                        ? const {
                            0: FlexColumnWidth(1.5),
                            1: FlexColumnWidth(1.3),
                            2: FlexColumnWidth(1.3),
                            3: FlexColumnWidth(1.3),
                            4: FlexColumnWidth(1.5),
                            5: FlexColumnWidth(1.2),
                            6: FlexColumnWidth(1.0),
                          }
                        : const {
                            0: FlexColumnWidth(1.8),
                            1: FlexColumnWidth(1.2),
                            2: FlexColumnWidth(1.3),
                            3: FlexColumnWidth(1.3),
                            4: FlexColumnWidth(1.5),
                            5: FlexColumnWidth(1.2),
                            6: FlexColumnWidth(1.0),
                          },
                    headers: isEmployee
                        ? const [
                            NeoTableHeaderCell('PERIODE'),
                            NeoTableHeaderCell('GAJI POKOK'),
                            NeoTableHeaderCell('LEMBUR'),
                            NeoTableHeaderCell('POTONGAN'),
                            NeoTableHeaderCell('GAJI BERSIH'),
                            NeoTableHeaderCell('STATUS'),
                            NeoTableHeaderCell('AKSI', alignment: Alignment.center),
                          ]
                        : const [
                            NeoTableHeaderCell('KARYAWAN'),
                            NeoTableHeaderCell('PERIODE'),
                            NeoTableHeaderCell('GAJI POKOK'),
                            NeoTableHeaderCell('LEMBUR'),
                            NeoTableHeaderCell('GAJI BERSIH'),
                            NeoTableHeaderCell('STATUS'),
                            NeoTableHeaderCell('AKSI', alignment: Alignment.center),
                          ],
                    rows: salaries.map((sal) {
                      if (isEmployee) {
                        return [
                          NeoTableCell(text: '${_getMonthName(sal.periodMonth)} ${sal.periodYear}'),
                          NeoTableCell(text: Utils.formatRupiah(sal.basicSalary)),
                          NeoTableCell(text: Utils.formatRupiah(sal.overtimeAmount)),
                          NeoTableCell(text: '− ${Utils.formatRupiah(sal.deductionAmount)}'),
                          NeoTableCell(text: Utils.formatRupiah(sal.netSalary), isBold: true),
                          NeoTableCell(child: NeoBadge.salary(sal.status)),
                          NeoTableCell(
                            alignment: Alignment.center,
                            child: NeoIconButton(
                              icon: Icons.receipt,
                              size: 32,
                              tooltip: 'Buka Slip',
                              onPressed: () => _showSalaryDetailsDialog(sal),
                            ),
                          ),
                        ];
                      } else {
                        return [
                          NeoTableCell(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                NeoAvatar(name: sal.employeeName, size: 28),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    sal.employeeName,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.neoBlack,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          NeoTableCell(text: '${_getMonthName(sal.periodMonth)} ${sal.periodYear}'),
                          NeoTableCell(text: Utils.formatRupiah(sal.basicSalary)),
                          NeoTableCell(text: Utils.formatRupiah(sal.overtimeAmount)),
                          NeoTableCell(text: Utils.formatRupiah(sal.netSalary), isBold: true),
                          NeoTableCell(child: NeoBadge.salary(sal.status)),
                          NeoTableCell(
                            alignment: Alignment.center,
                            child: NeoIconButton(
                              icon: Icons.visibility,
                              size: 32,
                              tooltip: 'Lihat Slip',
                              onPressed: () => _showSalaryDetailsDialog(sal),
                            ),
                          ),
                        ];
                      }
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
      },
    );
  }
}
