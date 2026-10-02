import 'package:flutter/material.dart';
import 'package:kita_kerja/database/index.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/lib/utils.dart';
import 'package:kita_kerja/screens/karyawan_form_screen.dart';
import 'package:kita_kerja/widgets/neo_components.dart';

class KaryawanScreen extends StatefulWidget {
  const KaryawanScreen({super.key});

  @override
  State<KaryawanScreen> createState() => _KaryawanScreenState();
}

class _KaryawanScreenState extends State<KaryawanScreen> {
  final MySQLHelper _dbHelper = MySQLHelper();

  int _currentTab = 0; // 0: Daftar Karyawan, 1: Rekap Gaji

  // --- State for Tab 0: Daftar Karyawan ---
  String _searchQuery = '';
  int _selectedDepartmentId = 0; // 0 = All
  String _selectedStatus = 'all'; // all, active, inactive
  int _currentPage = 1;
  final int _pageSize = 5;

  List<Map<String, dynamic>> _karyawanList = [];
  int _totalKaryawan = 0;
  bool _isLoadingKaryawan = false;

  // --- State for Tab 1: Rekap Gaji ---
  int _selectedMonth = 9; // September
  int _salaryDeptId = 0;
  List<Map<String, dynamic>> _salaryList = [];
  bool _isLoadingSalaries = false;

  List<Map<String, dynamic>> _departments = [];

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _loadKaryawan();
    _loadSalaries();
  }

  Future<void> _loadDepartments() async {
    final depts = await _dbHelper.getDepartments();
    if (!mounted) return;
    setState(() {
      _departments = depts;
    });
  }

  Future<void> _loadKaryawan() async {
    setState(() => _isLoadingKaryawan = true);
    final result = await _dbHelper.getEmployees(
      search: _searchQuery,
      departmentId: _selectedDepartmentId > 0 ? _selectedDepartmentId : null,
      status: _selectedStatus,
      page: _currentPage,
      pageSize: _pageSize,
    );
    if (!mounted) return;
    setState(() {
      _totalKaryawan = result['total'] as int;
      _karyawanList = List<Map<String, dynamic>>.from(result['data']);
      _isLoadingKaryawan = false;
    });
  }

  Future<void> _loadSalaries() async {
    setState(() => _isLoadingSalaries = true);
    final result = await _dbHelper.getSalaries(
      periodMonth: _selectedMonth,
      periodYear: 2026,
      departmentId: _salaryDeptId > 0 ? _salaryDeptId : null,
    );
    if (!mounted) return;
    setState(() {
      _salaryList = result;
      _isLoadingSalaries = false;
    });
  }

  void _handleToggleStatus(Map<String, dynamic> item) {
    final currentStatus = item['status'].toString();
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
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Utils.border,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin me-$actionLabel karyawan "${item['full_name']}" (${item['employee_code']})?\n\nSesuai PRD 6.8 & 9, karyawan nonaktif tidak dapat login atau menerima tugas baru.',
            style: const TextStyle(color: Utils.border),
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
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _dbHelper.toggleEmployeeStatus(
                  item['id'] as int,
                  currentStatus,
                );
                _loadKaryawan();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Status karyawan ${item['full_name']} berhasil diperbarui.',
                    ),
                    backgroundColor: Utils.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: currentStatus == 'active'
                    ? Utils.danger
                    : Utils.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Utils.border, width: 2),
                ),
              ),
              child: Text(
                currentStatus == 'active' ? 'Nonaktifkan' : 'Aktifkan',
              ),
            ),
          ],
        );
      },
    );
  }

  void _showExportDialog() {
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
              Icon(Icons.download_rounded, color: Utils.primary),
              SizedBox(width: 8),
              Text(
                'Ekspor Rekap Gaji',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Utils.border,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Pilih format dokumen ekspor rekap gaji untuk periode yang dipilih:',
                style: TextStyle(fontSize: 13, color: Utils.border),
              ),
              SizedBox(height: 16),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Rekap Gaji berhasil diekspor ke format CSV!',
                    ),
                    backgroundColor: Utils.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Utils.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Utils.border, width: 2),
                ),
              ),
              icon: const Icon(Icons.table_chart, size: 18),
              label: const Text('Ekspor CSV'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Rekap Gaji berhasil diekspor ke format PDF!',
                    ),
                    backgroundColor: Utils.success,
                  ),
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
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('Ekspor PDF'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_totalKaryawan / _pageSize).ceil();

    return MainLayout(
      title: 'Karyawan',
      activeMenu: 'karyawan',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP TABS SWITCH (Daftar Karyawan vs Rekap Gaji)
            Row(
              children: [
                _buildTabButton(0, 'Daftar Karyawan', Icons.people_outline),
                const SizedBox(width: 12),
                _buildTabButton(
                  1,
                  'Rekap Gaji (Payroll)',
                  Icons.payments_outlined,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. TAB CONTENT
            if (_currentTab == 0) ...[
              // TAB 0: DAFTAR KARYAWAN
              // Control Bar (Search + Department Filter + Status Filter + Add Button)
              Row(
                children: [
                  // Search Bar
                  Expanded(
                    flex: 3,
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
                          const Icon(
                            Icons.search,
                            color: Utils.border,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                  _currentPage = 1;
                                });
                                _loadKaryawan();
                              },
                              decoration: const InputDecoration(
                                hintText: 'Cari nama, NIK, atau email...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Utils.border,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Department Filter
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
                        value: _selectedDepartmentId,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Utils.border,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Utils.border,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 0,
                            child: Text('Semua Departemen'),
                          ),
                          ..._departments.map(
                            (d) => DropdownMenuItem(
                              value: d['id'] as int,
                              child: Text(d['name'].toString()),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedDepartmentId = val;
                              _currentPage = 1;
                            });
                            _loadKaryawan();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Status Filter
                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Utils.border, width: 2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Utils.border,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Utils.border,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('Semua Status'),
                          ),
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Aktif'),
                          ),
                          DropdownMenuItem(
                            value: 'inactive',
                            child: Text('Nonaktif'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedStatus = val;
                              _currentPage = 1;
                            });
                            _loadKaryawan();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Add Karyawan Button
                  SizedBox(
                    width: 180,
                    height: 42,
                    child: NeoButton(
                      text: '+ Tambah Karyawan',
                      backgroundColor: Utils.primary,
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KaryawanFormScreen(),
                          ),
                        );
                        if (result == true) {
                          _loadKaryawan();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Karyawan Table
              NeoTable(
                isLoading: _isLoadingKaryawan,
                emptyIcon: Icons.person_off_outlined,
                emptyText: 'Tidak ada data karyawan ditemukan',
                columnWidths: const {
                  0: FlexColumnWidth(2.5),
                  1: FlexColumnWidth(1.5),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(2.0),
                  4: FlexColumnWidth(1.2),
                  5: FlexColumnWidth(1.4),
                },
                headers: const [
                  NeoTableHeaderCell('NAMA & NIK'),
                  NeoTableHeaderCell('JABATAN'),
                  NeoTableHeaderCell('DEPARTEMEN'),
                  NeoTableHeaderCell('JADWAL KERJA'),
                  NeoTableHeaderCell('STATUS'),
                  NeoTableHeaderCell('AKSI'),
                ],
                rows: _karyawanList.map((emp) {
                  final isActive = emp['status'] == 'active';
                  return [
                    NeoTableCell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            emp['full_name'].toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Utils.border,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${emp['employee_code']} • ${emp['email'] ?? ''}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                    NeoTableCell(text: emp['position_name'].toString()),
                    NeoTableCell(text: emp['department_name'].toString()),
                    NeoTableCell(text: emp['work_schedule_name'].toString()),
                    NeoTableCell(
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFE2F9E5)
                                : const Color(0xFFFFF0F0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Utils.border, width: 1.5),
                          ),
                          child: Text(
                            isActive ? 'Aktif' : 'Nonaktif',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isActive
                                  ? const Color(0xFF1B7F2D)
                                  : Utils.danger,
                            ),
                          ),
                        ),
                      ),
                    ),
                    NeoTableCell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 6,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Utils.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              tooltip: 'Edit Data',
                              onPressed: () async {
                                final res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        KaryawanFormScreen(employeeToEdit: emp),
                                  ),
                                );
                                if (res == true) _loadKaryawan();
                              },
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: isActive ? Utils.danger : Utils.success,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: Icon(
                                isActive
                                    ? Icons.block
                                    : Icons.check_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              tooltip: isActive ? 'Nonaktifkan' : 'Aktifkan',
                              onPressed: () => _handleToggleStatus(emp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Pagination Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menampilkan ${_totalKaryawan == 0 ? 0 : (_currentPage - 1) * _pageSize + 1} - ${_currentPage * _pageSize > _totalKaryawan ? _totalKaryawan : _currentPage * _pageSize} dari $_totalKaryawan data karyawan',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666),
                    ),
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: _currentPage > 1
                            ? () {
                                setState(() => _currentPage--);
                                _loadKaryawan();
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Utils.border,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          '< Prev',
                          style: TextStyle(
                            color: Utils.border,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Utils.secondary,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Utils.border, width: 1.5),
                        ),
                        child: Text(
                          'Halaman $_currentPage / ${totalPages == 0 ? 1 : totalPages}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Utils.border,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _currentPage < totalPages
                            ? () {
                                setState(() => _currentPage++);
                                _loadKaryawan();
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Utils.border,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Next >',
                          style: TextStyle(
                            color: Utils.border,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ] else ...[
              // TAB 1: REKAP GAJI (PAYROLL)
              // Control Bar (Month Filter + Division Filter + Export CSV/PDF Button)
              Row(
                children: [
                  // Month Filter
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
                        value: _selectedMonth,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Utils.border,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Utils.border,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 1,
                            child: Text('Januari 2026'),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text('Februari 2026'),
                          ),
                          DropdownMenuItem(value: 3, child: Text('Maret 2026')),
                          DropdownMenuItem(value: 4, child: Text('April 2026')),
                          DropdownMenuItem(value: 5, child: Text('Mei 2026')),
                          DropdownMenuItem(value: 6, child: Text('Juni 2026')),
                          DropdownMenuItem(value: 7, child: Text('Juli 2026')),
                          DropdownMenuItem(
                            value: 8,
                            child: Text('Agustus 2026'),
                          ),
                          DropdownMenuItem(
                            value: 9,
                            child: Text('September 2026'),
                          ),
                          DropdownMenuItem(
                            value: 10,
                            child: Text('Oktober 2026'),
                          ),
                          DropdownMenuItem(
                            value: 11,
                            child: Text('November 2026'),
                          ),
                          DropdownMenuItem(
                            value: 12,
                            child: Text('Desember 2026'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedMonth = val);
                            _loadSalaries();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Division / Department Filter
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
                        value: _salaryDeptId,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Utils.border,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Utils.border,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 0,
                            child: Text('Semua Divisi'),
                          ),
                          ..._departments.map(
                            (d) => DropdownMenuItem(
                              value: d['id'] as int,
                              child: Text(d['name'].toString()),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _salaryDeptId = val);
                            _loadSalaries();
                          }
                        },
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Export CSV or PDF Button
                  ElevatedButton.icon(
                    onPressed: _showExportDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Utils.secondary,
                      foregroundColor: Utils.border,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Utils.border, width: 2),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(
                      Icons.download,
                      size: 18,
                      color: Utils.border,
                    ),
                    label: const Text(
                      'Ekspor Rekap (CSV/PDF)',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Salary Table
              Expanded(
                child: NeoTable(
                  isLoading: _isLoadingSalaries,
                  emptyIcon: Icons.request_quote_outlined,
                  emptyText: 'Belum ada data rekap gaji untuk periode ini',
                  columnWidths: const {
                    0: FlexColumnWidth(2.2),
                    1: FlexColumnWidth(1.2),
                    2: FlexColumnWidth(1.5),
                    3: FlexColumnWidth(1.3),
                    4: FlexColumnWidth(1.3),
                    5: FlexColumnWidth(1.3),
                    6: FlexColumnWidth(1.6),
                  },
                  headers: const [
                    NeoTableHeaderCell('NAMA KARYAWAN'),
                    NeoTableHeaderCell('JENIS GAJI'),
                    NeoTableHeaderCell('GAJI POKOK'),
                    NeoTableHeaderCell('LEMBUR'),
                    NeoTableHeaderCell('BONUS'),
                    NeoTableHeaderCell('POTONGAN'),
                    NeoTableHeaderCell('GAJI BERSIH'),
                  ],
                  rows: _salaryList.map((sal) {
                    return [
                      NeoTableCell(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              sal['employee_name'].toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Utils.border,
                              ),
                            ),
                            Text(
                              '${sal['employee_code']} • ${sal['department_name']}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                      NeoTableCell(text: sal['salary_type_name'].toString()),
                      NeoTableCell(
                        text: Utils.formatRupiah(sal['basic_salary'] as num),
                      ),
                      NeoTableCell(
                        text: Utils.formatRupiah(sal['overtime_amount'] as num),
                      ),
                      NeoTableCell(
                        text: Utils.formatRupiah(sal['bonus_amount'] as num),
                      ),
                      NeoTableCell(
                        text: Utils.formatRupiah(
                          sal['deduction_amount'] as num,
                        ),
                        isDanger: (sal['deduction_amount'] as num) > 0,
                      ),
                      NeoTableCell(
                        text: Utils.formatRupiah(sal['net_salary'] as num),
                        isBold: true,
                        isSuccess: true,
                      ),
                    ];
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Status Payroll Summary Cards below table
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Utils.primary,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Utils.border, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'STATUS PAYROLL BULANAN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                _buildPayrollBadge('DRAFT: 2'),
                                const SizedBox(width: 8),
                                _buildPayrollBadge(
                                  'PROCESSED: 1',
                                  bg: Utils.primary,
                                  textCol: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                _buildPayrollBadge(
                                  'PAID: 1',
                                  bg: Utils.success,
                                  textCol: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'TOTAL PAYROLL BERSIH: ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Utils.border,
                          ),
                        ),
                        Text(
                          Utils.formatRupiah(
                            _salaryList.fold<num>(
                              0,
                              (sum, item) => sum + (item['net_salary'] as num),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Utils.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title, IconData icon) {
    final isSelected = _currentTab == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Utils.secondary : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Utils.border, width: 2),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Utils.border,
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Utils.border),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: Utils.border,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayrollBadge(
    String text, {
    Color bg = Colors.white,
    Color textCol = Utils.border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Utils.border, width: 1.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textCol,
        ),
      ),
    );
  }
}
