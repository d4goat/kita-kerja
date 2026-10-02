import 'package:flutter/material.dart';
import 'package:kita_kerja/database/index.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/lib/utils.dart';
import 'package:kita_kerja/widgets/neo_components.dart';

class PekerjaanScreen extends StatefulWidget {
  const PekerjaanScreen({super.key});

  @override
  State<PekerjaanScreen> createState() => _PekerjaanScreenState();
}

class _PekerjaanScreenState extends State<PekerjaanScreen> {
  final MySQLHelper _dbHelper = MySQLHelper();
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final data = await _dbHelper.getTasks();
    if (!mounted) return;
    setState(() {
      _tasks = data;
      _isLoading = false;
    });
  }

  Color _getPriorityBg(String priority) {
    switch (priority) {
      case 'urgent':
        return const Color(0xFFFFF0F0);
      case 'high':
        return const Color(0xFFFFF7DB);
      case 'medium':
        return const Color(0xFFE5F0FF);
      case 'low':
      default:
        return const Color(0xFFF0F0F0);
    }
  }

  Color _getPriorityText(String priority) {
    switch (priority) {
      case 'urgent':
        return Utils.danger;
      case 'high':
        return const Color(0xFF8C6600);
      case 'medium':
        return Utils.primary;
      case 'low':
      default:
        return const Color(0xFF666666);
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'not_started':
        return 'Belum Mulai';
      case 'in_progress':
        return 'Sedang Dikerjakan';
      case 'review':
        return 'Ditinjau';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFFE2F9E5);
      case 'in_progress':
        return Utils.primary;
      case 'review':
        return Utils.secondary;
      case 'not_started':
      default:
        return Colors.white;
    }
  }

  Color _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF1B7F2D);
      case 'in_progress':
        return Colors.white;
      case 'review':
        return Utils.border;
      case 'not_started':
      default:
        return Utils.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _tasks.where((item) {
      final title = item['title'].toString().toLowerCase();
      final emp = item['assigned_to_name'].toString().toLowerCase();
      final cat = item['category_name'].toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      final matchSearch =
          title.contains(q) || emp.contains(q) || cat.contains(q);
      final matchStatus =
          _selectedStatus == 'all' || item['status'] == _selectedStatus;
      return matchSearch && matchStatus;
    }).toList();

    return MainLayout(
      title: 'Manajemen Pekerjaan',
      activeMenu: 'pekerjaan',
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Controls Bar
            Row(
              children: [
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
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                            decoration: const InputDecoration(
                              hintText: 'Cari judul tugas, penanggung jawab, atau kategori...',
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
                const SizedBox(width: 16),
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
                          value: 'not_started',
                          child: Text('Belum Mulai'),
                        ),
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text('Sedang Dikerjakan'),
                        ),
                        DropdownMenuItem(
                          value: 'review',
                          child: Text('Ditinjau'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Selesai'),
                        ),
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

            // Tasks Table
            NeoTable(
                isLoading: _isLoading,
                emptyIcon: Icons.assignment_turned_in_outlined,
                emptyText: 'Tidak ada pekerjaan ditemukan',
                columnWidths: const {
                  0: FlexColumnWidth(2.5),
                  1: FlexColumnWidth(1.2),
                  2: FlexColumnWidth(1.6),
                  3: FlexColumnWidth(1.1),
                  4: FlexColumnWidth(1.2),
                  5: FlexColumnWidth(1.4),
                },
                headers: const [
                  NeoTableHeaderCell('JUDUL TUGAS'),
                  NeoTableHeaderCell('KATEGORI'),
                  NeoTableHeaderCell('PENANGGUNG JAWAB'),
                  NeoTableHeaderCell('PRIORITAS'),
                  NeoTableHeaderCell('DEADLINE'),
                  NeoTableHeaderCell('STATUS'),
                ],
                rows: filtered.map((task) {
                  final priority = task['priority'].toString();
                  final st = task['status'].toString();
                  return [
                    NeoTableCell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            task['title'].toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Utils.border,
                            ),
                          ),
                          if (task['description'].toString().isNotEmpty)
                            Text(
                              task['description'].toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF666666),
                              ),
                            ),
                        ],
                      ),
                    ),
                    NeoTableCell(text: task['category_name'].toString()),
                    NeoTableCell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            task['assigned_to_name'].toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Utils.border,
                            ),
                          ),
                          Text(
                            task['employee_code'].toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Priority Badge
                    NeoTableCell(
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityBg(priority),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Utils.border,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            priority.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _getPriorityText(priority),
                            ),
                          ),
                        ),
                      ),
                    ),
                    NeoTableCell(text: task['deadline'].toString()),
                    // Status Badge
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
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Utils.border,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            _getStatusLabel(st),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _getStatusText(st),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ];
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
