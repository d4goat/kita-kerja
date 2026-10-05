import 'package:flutter/material.dart';
import 'package:kita_kerja/database/index.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/lib/utils.dart';
import 'package:kita_kerja/widgets/neo_components.dart';

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
            NeoTable(
                isLoading: _isLoading,
                emptyIcon: Icons.event_busy,
                emptyText: 'Tidak ada riwayat kehadiran ditemukan',
                columnWidths: const {
                  0: FlexColumnWidth(2.0),
                  1: FlexColumnWidth(1.2),
                  2: FlexColumnWidth(1.0),
                  3: FlexColumnWidth(1.0),
                  4: FlexColumnWidth(1.2),
                  5: FlexColumnWidth(1.2),
                  6: FlexColumnWidth(1.8),
                },
                headers: const [
                  NeoTableHeaderCell('KARYAWAN'),
                  NeoTableHeaderCell('TANGGAL'),
                  NeoTableHeaderCell('MASUK'),
                  NeoTableHeaderCell('PULANG'),
                  NeoTableHeaderCell('JAM KERJA'),
                  NeoTableHeaderCell('STATUS'),
                  NeoTableHeaderCell('CATATAN'),
                ],
                rows: filtered.map((att) {
                  final st = att['status'].toString();
                  return [
                    NeoTableCell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            att['employee_name'].toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Utils.border,
                            ),
                          ),
                          Text(
                            '${att['employee_code']} • ${att['department_name']}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                    NeoTableCell(text: att['attendance_date'].toString()),
                    NeoTableCell(text: att['clock_in'].toString()),
                    NeoTableCell(text: att['clock_out'].toString()),
                    NeoTableCell(text: '${att['working_hours']} Jam'),
                    NeoTableCell(
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusBg(st),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Utils.border,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            _getStatusLabel(st),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _getStatusText(st),
                            ),
                          ),
                        ),
                      ),
                    ),
                    NeoTableCell(text: (att['notes'] ?? '-').toString()),
                  ];
                }).toList(),
              ),
            ],
          ),
        ),
    );
  }
}
