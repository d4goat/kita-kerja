import 'package:flutter/material.dart';
import 'package:kita_kerja/database/index.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/lib/utils.dart';

class KehadiranScreen extends StatefulWidget {
  const KehadiranScreen({super.key});

  @override
  State<KehadiranScreen> createState() => _KehadiranScreenState();
}

class _KehadiranScreenState extends State<KehadiranScreen> {
  final MySQLHelper _dbHelper = MySQLHelper();
  List<Map<String, dynamic>> _attendances = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadAttendances();
  }

  Future<void> _loadAttendances() async {
    setState(() => _isLoading = true);
    final data = await _dbHelper.getAttendances();
    if (!mounted) return;
    setState(() {
      _attendances = data;
      _isLoading = false;
    });
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'present':
        return const Color(0xFFE2F9E5);
      case 'late':
        return const Color(0xFFFFF7DB);
      case 'sick':
      case 'leave':
        return const Color(0xFFE5F0FF);
      case 'absent':
      default:
        return const Color(0xFFFFF0F0);
    }
  }

  Color _getStatusText(String status) {
    switch (status) {
      case 'present':
        return const Color(0xFF1B7F2D);
      case 'late':
        return const Color(0xFF8C6600);
      case 'sick':
      case 'leave':
        return Utils.primary;
      case 'absent':
      default:
        return Utils.danger;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'present':
        return 'Hadir';
      case 'late':
        return 'Terlambat';
      case 'sick':
        return 'Sakit';
      case 'leave':
        return 'Cuti';
      case 'absent':
      default:
        return 'Alpa';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _attendances.where((item) {
      final name = item['employee_name'].toString().toLowerCase();
      final code = item['employee_code'].toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      final matchSearch = name.contains(q) || code.contains(q);
      final matchStatus = _selectedStatus == 'all' || item['status'] == _selectedStatus;
      return matchSearch && matchStatus;
    }).toList();

    return MainLayout(
      title: 'Presensi & Kehadiran',
      activeMenu: 'kehadiran',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Bar
            Row(
              children: [
                // Search Input
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
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: const InputDecoration(
                              hintText: 'Cari nama atau NIK karyawan...',
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
                      icon: const Icon(Icons.arrow_drop_down, color: Utils.border),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Utils.border),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Semua Status')),
                        DropdownMenuItem(value: 'present', child: Text('Hadir')),
                        DropdownMenuItem(value: 'late', child: Text('Terlambat')),
                        DropdownMenuItem(value: 'sick', child: Text('Sakit')),
                        DropdownMenuItem(value: 'leave', child: Text('Cuti')),
                        DropdownMenuItem(value: 'absent', child: Text('Alpa')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStatus = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Attendances Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Utils.border, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Utils.border,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Utils.primary))
                    : filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.event_busy, size: 48, color: Color(0xFF888888)),
                                SizedBox(height: 12),
                                Text('Tidak ada riwayat kehadiran ditemukan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Utils.border)),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(2.0),
                                1: FlexColumnWidth(1.2),
                                2: FlexColumnWidth(1.0),
                                3: FlexColumnWidth(1.0),
                                4: FlexColumnWidth(1.2),
                                5: FlexColumnWidth(1.2),
                                6: FlexColumnWidth(1.8),
                              },
                              border: const TableBorder(
                                horizontalInside: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                              ),
                              children: [
                                TableRow(
                                  decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
                                  children: [
                                    _buildHeaderCell('KARYAWAN'),
                                    _buildHeaderCell('TANGGAL'),
                                    _buildHeaderCell('MASUK'),
                                    _buildHeaderCell('PULANG'),
                                    _buildHeaderCell('JAM KERJA'),
                                    _buildHeaderCell('STATUS'),
                                    _buildHeaderCell('CATATAN'),
                                  ],
                                ),
                                ...filtered.map((att) {
                                  final st = att['status'].toString();
                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(att['employee_name'].toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Utils.border)),
                                            Text('${att['employee_code']} • ${att['department_name']}', style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
                                          ],
                                        ),
                                      ),
                                      _buildBodyCell(att['attendance_date'].toString()),
                                      _buildBodyCell(att['clock_in'].toString()),
                                      _buildBodyCell(att['clock_out'].toString()),
                                      _buildBodyCell('${att['working_hours']} Jam'),
                                      // Status Badge
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusBg(st),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Utils.border, width: 1.5),
                                            ),
                                            child: Text(
                                              _getStatusLabel(st),
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _getStatusText(st)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      _buildBodyCell((att['notes'] ?? '-').toString()),
                                    ],
                                  );
                                }),
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

  Widget _buildHeaderCell(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF666666), letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildBodyCell(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Text(
        content,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Utils.border),
      ),
    );
  }
}
