import 'package:flutter/material.dart';
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
      Provider.of<EmployeeController>(context, listen: false).loadEmployees();
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
    final actionLabel = currentStatus == 'active' ? 'nonaktifkan' : 'aktifkan';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Utils.border, width: 2),
          ),
          title: Text(
            'Konfirmasi $actionLabel Karyawan',
            style: const TextStyle(fontWeight: FontWeight.w800, color: Utils.border),
          ),
          content: Text(
            'Apakah Anda yakin ingin me-$actionLabel karyawan "${item.fullName}" (${item.employeeCode})?',
            style: const TextStyle(color: Utils.border),
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
              onPressed: () async {
                Navigator.pop(dialogContext);
                final ok = await controller.toggleEmployeeStatus(item.id, currentStatus);
                if (ok && mounted) {
                  Utils.toast(
                    context,
                    'Karyawan "${item.fullName}" berhasil di-$actionLabel!',
                    ToastificationType.success,
                    Icons.check,
                    Utils.success,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: currentStatus == 'active' ? Utils.danger : Utils.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Utils.border, width: 2),
                ),
              ),
              child: Text(actionLabel.toUpperCase()),
            ),
          ],
        );
      },
    );
  }

  void _showSalaryDetailsDialog(SalaryModel sal) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Utils.border, width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.receipt_long, color: Utils.primary),
              const SizedBox(width: 8),
              Text(
                'Rincian Slip Gaji: ${sal.employeeName}',
                style: const TextStyle(fontWeight: FontWeight.w800, color: Utils.border, fontSize: 16),
              ),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReceiptRow('Periode', '${_getMonthName(sal.periodMonth)} ${sal.periodYear}'),
                _buildReceiptRow('NIK / Departemen', '${sal.employeeCode} • ${sal.departmentName}'),
                _buildReceiptRow('Jenis Gaji', sal.salaryTypeName),
                const Divider(height: 20, thickness: 1.5),
                _buildReceiptRow('Gaji Pokok (+)', Utils.formatRupiah(sal.basicSalary)),
                _buildReceiptRow('Lembur (+)', Utils.formatRupiah(sal.overtimeAmount)),
                _buildReceiptRow('Bonus (+)', Utils.formatRupiah(sal.bonusAmount)),
                _buildReceiptRow('Potongan (-)', Utils.formatRupiah(sal.deductionAmount), isNegative: true),
                const Divider(height: 20, thickness: 2, color: Utils.border),
                _buildReceiptRow('Gaji Bersih (Take Home Pay)', Utils.formatRupiah(sal.netSalary), isTotal: true),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status Pembayaran:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSalaryStatusBg(sal.status),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Utils.border, width: 1.5),
                      ),
                      child: Text(
                        sal.statusLabel,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _getSalaryStatusText(sal.status)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Utils.border, width: 2)),
              child: const Text('Tutup', style: TextStyle(color: Utils.border)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isNegative = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
              color: Utils.border,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
              color: isNegative ? Utils.danger : (isTotal ? Utils.primary : Utils.border),
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

  Color _getSalaryStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFFE2F9E5);
      case 'processed':
        return const Color(0xFFFFF7DB);
      case 'draft':
      default:
        return const Color(0xFFF0F0F0);
    }
  }

  Color _getSalaryStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFF1B7F2D);
      case 'processed':
        return const Color(0xFF8C6600);
      case 'draft':
      default:
        return const Color(0xFF666666);
    }
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _currentTab == index;
    return InkWell(
      onTap: () => setState(() => _currentTab = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Utils.secondary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Utils.border, width: 2),
          boxShadow: isSelected ? const [BoxShadow(color: Utils.border, offset: Offset(2, 2), blurRadius: 0)] : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Utils.border),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Utils.border)),
          ],
        ),
      ),
    );
  }

  // View khusus Karyawan: Slip Gaji Pribadi
  Widget _buildEmployeeSlipGajiView(SalaryController salaryCtrl, AuthController auth) {
    final list = salaryCtrl.mySalaries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Employee Info Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Utils.border, width: 2),
            boxShadow: const [BoxShadow(color: Utils.border, offset: Offset(4, 4), blurRadius: 0)],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Utils.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Utils.border, width: 2),
                ),
                child: const Icon(Icons.receipt_long, color: Utils.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Kompensasi & Slip Gaji',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Utils.border),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nama: ${auth.currentUser?.name} • NIK: ${auth.currentUser?.employeeCode ?? 'EMP003'} • Departemen: ${auth.currentUser?.departmentName ?? 'Operasional'}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF666666), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Salary Table for this employee
        NeoTable(
          isLoading: salaryCtrl.isLoading,
          emptyIcon: Icons.payments_outlined,
          emptyText: 'Belum ada data slip gaji untuk akun Anda',
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(1.4),
            2: FlexColumnWidth(1.1),
            3: FlexColumnWidth(1.1),
            4: FlexColumnWidth(1.1),
            5: FlexColumnWidth(1.5),
            6: FlexColumnWidth(1.2),
            7: FlexColumnWidth(1.1),
          },
          headers: const [
            NeoTableHeaderCell('PERIODE'),
            NeoTableHeaderCell('GAJI POKOK'),
            NeoTableHeaderCell('LEMBUR'),
            NeoTableHeaderCell('BONUS'),
            NeoTableHeaderCell('POTONGAN'),
            NeoTableHeaderCell('GAJI BERSIH'),
            NeoTableHeaderCell('STATUS'),
            NeoTableHeaderCell('AKSI'),
          ],
          rows: list.map((sal) {
            return [
              NeoTableCell(text: '${_getMonthName(sal.periodMonth)} ${sal.periodYear}'),
              NeoTableCell(text: Utils.formatRupiah(sal.basicSalary)),
              NeoTableCell(text: Utils.formatRupiah(sal.overtimeAmount)),
              NeoTableCell(text: Utils.formatRupiah(sal.bonusAmount)),
              NeoTableCell(text: Utils.formatRupiah(sal.deductionAmount)),
              NeoTableCell(
                child: Text(
                  Utils.formatRupiah(sal.netSalary),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Utils.primary),
                ),
              ),
              NeoTableCell(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSalaryStatusBg(sal.status),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Utils.border, width: 1.5),
                    ),
                    child: Text(
                      sal.statusLabel,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _getSalaryStatusText(sal.status)),
                    ),
                  ),
                ),
              ),
              NeoTableCell(
                child: Align(
                  alignment: Alignment.center,
                  child: OutlinedButton(
                    onPressed: () => _showSalaryDetailsDialog(sal),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Utils.border, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: const Text('Rincian', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Utils.border)),
                  ),
                ),
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
    final isEmployee = auth.isEmployee;

    return Consumer2<EmployeeController, SalaryController>(
      builder: (context, empCtrl, salaryCtrl, child) {
        return MainLayout(
          title: isEmployee ? 'Slip Gaji Saya' : 'Karyawan & Kompensasi',
          activeMenu: 'karyawan',
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: isEmployee
                ? _buildEmployeeSlipGajiView(salaryCtrl, auth)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Tabs
                      Row(
                        children: [
                          _buildTabButton(0, 'Daftar Karyawan', Icons.people_outline),
                          const SizedBox(width: 12),
                          _buildTabButton(1, 'Rekap Gaji (Payroll)', Icons.payments_outlined),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // TAB 0: DAFTAR KARYAWAN
                      if (_currentTab == 0) ...[
                        // Controls Bar
                        Row(
                          children: [
                            // Search
                            Expanded(
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Utils.border, width: 2),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.search, color: Utils.border, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        onChanged: (val) => empCtrl.setSearchQuery(val),
                                        decoration: const InputDecoration(
                                          hintText: 'Cari nama, NIK, atau email karyawan...',
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          isDense: true,
                                        ),
                                        style: const TextStyle(fontSize: 14, color: Utils.border),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Dept Filter
                            Container(
                              height: 42,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Utils.border, width: 2),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: empCtrl.selectedDepartmentId,
                                  icon: const Icon(Icons.arrow_drop_down, color: Utils.border),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Utils.border),
                                  items: [
                                    const DropdownMenuItem(value: 0, child: Text('Semua Departemen')),
                                    ..._departments.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) empCtrl.setSelectedDepartmentId(val);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Add Employee Button (Admin only)
                            if (auth.isAdmin)
                              SizedBox(
                                width: 190,
                                height: 42,
                                child: NeoButton(
                                  text: '+ Tambah Karyawan',
                                  backgroundColor: Utils.primary,
                                  onPressed: () async {
                                    final res = await Navigator.pushNamed(context, '/karyawan-form');
                                    if (res == true && mounted) {
                                      empCtrl.loadEmployees();
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Employee Table
                        NeoTable(
                          isLoading: empCtrl.isLoading,
                          emptyIcon: Icons.people_outline,
                          emptyText: 'Tidak ada data karyawan ditemukan',
                          columnWidths: const {
                            0: FlexColumnWidth(2.0),
                            1: FlexColumnWidth(1.2),
                            2: FlexColumnWidth(1.2),
                            3: FlexColumnWidth(1.2),
                            4: FlexColumnWidth(1.0),
                            5: FlexColumnWidth(1.2),
                          },
                          headers: const [
                            NeoTableHeaderCell('KARYAWAN'),
                            NeoTableHeaderCell('JABATAN'),
                            NeoTableHeaderCell('DEPARTEMEN'),
                            NeoTableHeaderCell('JADWAL KERJA'),
                            NeoTableHeaderCell('STATUS'),
                            NeoTableHeaderCell('AKSI'),
                          ],
                          rows: empCtrl.employees.map((emp) {
                            return [
                              NeoTableCell(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(emp.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Utils.border)),
                                    Text('${emp.employeeCode} • ${emp.email}', style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
                                  ],
                                ),
                              ),
                              NeoTableCell(text: emp.positionName),
                              NeoTableCell(text: emp.departmentName),
                              NeoTableCell(text: emp.workScheduleName),
                              NeoTableCell(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: emp.isActive ? const Color(0xFFE2F9E5) : const Color(0xFFFFF0F0),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Utils.border, width: 1.5),
                                    ),
                                    child: Text(
                                      emp.isActive ? 'Aktif' : 'Nonaktif',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: emp.isActive ? const Color(0xFF1B7F2D) : Utils.danger,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              NeoTableCell(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Utils.primary, size: 18),
                                      tooltip: 'Edit Detail',
                                      onPressed: () async {
                                        final res = await Navigator.pushNamed(context, '/karyawan-form', arguments: emp.toMap());
                                        if (res == true && mounted) {
                                          empCtrl.loadEmployees();
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        emp.isActive ? Icons.toggle_on : Icons.toggle_off,
                                        color: emp.isActive ? Utils.success : Colors.grey,
                                        size: 26,
                                      ),
                                      tooltip: emp.isActive ? 'Nonaktifkan' : 'Aktifkan',
                                      onPressed: () => _handleToggleStatus(emp, empCtrl),
                                    ),
                                  ],
                                ),
                              ),
                            ];
                          }).toList(),
                        ),
                      ] else ...[
                        // TAB 1: REKAP GAJI
                        Row(
                          children: [
                            // Month Selector
                            Container(
                              height: 42,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Utils.border, width: 2),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: salaryCtrl.selectedMonth,
                                  icon: const Icon(Icons.arrow_drop_down, color: Utils.border),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Utils.border),
                                  items: List.generate(12, (index) => DropdownMenuItem(value: index + 1, child: Text(_getMonthName(index + 1)))),
                                  onChanged: (val) {
                                    if (val != null) {
                                      salaryCtrl.setSelectedMonth(val);
                                      salaryCtrl.loadSalaries(auth.currentUser);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Dept Filter
                            Container(
                              height: 42,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Utils.border, width: 2),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: salaryCtrl.selectedDeptId,
                                  icon: const Icon(Icons.arrow_drop_down, color: Utils.border),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Utils.border),
                                  items: [
                                    const DropdownMenuItem(value: 0, child: Text('Semua Departemen')),
                                    ..._departments.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      salaryCtrl.setSelectedDeptId(val);
                                      salaryCtrl.loadSalaries(auth.currentUser);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Salaries Table
                        NeoTable(
                          isLoading: salaryCtrl.isLoading,
                          emptyIcon: Icons.payments_outlined,
                          emptyText: 'Tidak ada data rekap gaji untuk periode ini',
                          columnWidths: const {
                            0: FlexColumnWidth(1.8),
                            1: FlexColumnWidth(1.2),
                            2: FlexColumnWidth(1.2),
                            3: FlexColumnWidth(1.0),
                            4: FlexColumnWidth(1.0),
                            5: FlexColumnWidth(1.4),
                            6: FlexColumnWidth(1.1),
                            7: FlexColumnWidth(1.0),
                          },
                          headers: const [
                            NeoTableHeaderCell('KARYAWAN'),
                            NeoTableHeaderCell('GAJI POKOK'),
                            NeoTableHeaderCell('LEMBUR'),
                            NeoTableHeaderCell('BONUS'),
                            NeoTableHeaderCell('POTONGAN'),
                            NeoTableHeaderCell('GAJI BERSIH'),
                            NeoTableHeaderCell('STATUS'),
                            NeoTableHeaderCell('AKSI'),
                          ],
                          rows: salaryCtrl.salaries.map((sal) {
                            return [
                              NeoTableCell(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(sal.employeeName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Utils.border)),
                                    Text('${sal.employeeCode} • ${sal.departmentName}', style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
                                  ],
                                ),
                              ),
                              NeoTableCell(text: Utils.formatRupiah(sal.basicSalary)),
                              NeoTableCell(text: Utils.formatRupiah(sal.overtimeAmount)),
                              NeoTableCell(text: Utils.formatRupiah(sal.bonusAmount)),
                              NeoTableCell(text: Utils.formatRupiah(sal.deductionAmount)),
                              NeoTableCell(
                                child: Text(
                                  Utils.formatRupiah(sal.netSalary),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Utils.primary),
                                ),
                              ),
                              NeoTableCell(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getSalaryStatusBg(sal.status),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Utils.border, width: 1.5),
                                    ),
                                    child: Text(
                                      sal.statusLabel,
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _getSalaryStatusText(sal.status)),
                                    ),
                                  ),
                                ),
                              ),
                              NeoTableCell(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: IconButton(
                                    icon: const Icon(Icons.info_outline, color: Utils.primary, size: 20),
                                    tooltip: 'Lihat Rincian Slip Gaji',
                                    onPressed: () => _showSalaryDetailsDialog(sal),
                                  ),
                                ),
                              ),
                            ];
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }
}
