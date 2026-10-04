import 'package:flutter/material.dart';
import 'package:kita_kerja/database/index.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/lib/utils.dart';
import 'package:kita_kerja/widgets/neo_components.dart';
import 'package:toastification/toastification.dart';

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

  void _handleQuickStatusDialog(Map<String, dynamic> task) {
    final currentStatus = task['status'].toString();
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
            'Ubah Status Pekerjaan',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Utils.border,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tugas: "${task['title']}"',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Utils.border,
                ),
              ),
              const SizedBox(height: 16),
              ...[
                {
                  'val': 'not_started',
                  'label': 'Belum Mulai',
                  'color': Colors.grey,
                },
                {
                  'val': 'in_progress',
                  'label': 'Sedang Dikerjakan',
                  'color': Utils.primary,
                },
                {
                  'val': 'review',
                  'label': 'Ditinjau (Review)',
                  'color': Utils.secondary,
                },
                {
                  'val': 'completed',
                  'label': 'Selesai (Completed)',
                  'color': Utils.success,
                },
              ].map((opt) {
                final isSelected = opt['val'] == currentStatus;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      Navigator.pop(dialogContext);
                      final newVal = opt['val'] as String;
                      if (newVal != currentStatus) {
                        await _dbHelper.updateTaskStatus(
                          task['id'] as int,
                          newVal,
                        );
                        _loadTasks();
                        if (!mounted) return;
                        Utils.toast(
                          context,
                          'Status tugas diubah menjadi ${_getStatusLabel(newVal)}',
                          ToastificationType.success,
                          Icons.check,
                          Utils.success,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF5F1E8)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Utils.border
                              : const Color(0xFFE0E0E0),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: opt['color'] as Color,
                              border: Border.all(
                                color: Utils.border,
                                width: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              opt['label'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: Utils.border,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Utils.primary,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
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
              child: const Text('Tutup', style: TextStyle(color: Utils.border)),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteTask(Map<String, dynamic> task) {
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
            'Konfirmasi Hapus Pekerjaan',
            style: TextStyle(fontWeight: FontWeight.w800, color: Utils.border),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus pekerjaan "${task['title']}"?\nTindakan ini tidak dapat dibatalkan.',
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
                await _dbHelper.deleteTask(task['id'] as int);
                _loadTasks();
                if (!mounted) return;
                Utils.toast(
                  context,
                  'Pekerjaan "${task['title']}" berhasil dihapus',
                  ToastificationType.success,
                  Icons.delete_outline,
                  Utils.danger,
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
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls Bar
            Row(
              children: [
                // Search Box
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
                // Filter Status Dropdown
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
                const SizedBox(width: 16),
                // Button Tambah Pekerjaan
                SizedBox(
                  width: 200,
                  height: 42,
                  child: NeoButton(
                    text: '+ Tambah Pekerjaan',
                    backgroundColor: Utils.primary,
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/pekerjaan-form',
                      );
                      if (result == true) {
                        _loadTasks();
                      }
                    },
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
                0: FlexColumnWidth(2.3),
                1: FlexColumnWidth(1.2),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.0),
                4: FlexColumnWidth(1.1),
                5: FlexColumnWidth(1.6),
                6: FlexColumnWidth(1.3),
              },
              headers: const [
                NeoTableHeaderCell('JUDUL TUGAS'),
                NeoTableHeaderCell('KATEGORI'),
                NeoTableHeaderCell('PENANGGUNG JAWAB'),
                NeoTableHeaderCell('PRIORITAS'),
                NeoTableHeaderCell('DEADLINE'),
                NeoTableHeaderCell('STATUS'),
                NeoTableHeaderCell('AKSI'),
              ],
              rows: filtered.map((task) {
                final priority = task['priority'].toString();
                final st = task['status'].toString();
                return [
                  // Judul & Deskripsi
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF666666),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Kategori
                  NeoTableCell(text: task['category_name'].toString()),
                  // Penanggung Jawab
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
                          border: Border.all(color: Utils.border, width: 1.5),
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
                  // Deadline
                  NeoTableCell(text: task['deadline'].toString()),
                  // Status Badge with Click to Change
                  NeoTableCell(
                    child: Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () => _handleQuickStatusDialog(task),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusBg(st),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Utils.border, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getStatusLabel(st),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: _getStatusText(st),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 14,
                                color: _getStatusText(st),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Aksi (Edit & Delete Buttons)
                  NeoTableCell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Edit Button
                        Container(
                          decoration: BoxDecoration(
                            color: Utils.secondary,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(width: 1.5, color: Utils.border),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Utils.border,
                            ),
                            tooltip: 'Sunting Pekerjaan',
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                            onPressed: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                '/pekerjaan-form',
                                arguments: task,
                              );
                              if (result == true) {
                                _loadTasks();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Delete Button
                        Container(
                          decoration: BoxDecoration(
                            color: Utils.danger,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(width: 1.5, color: Utils.border),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Colors.white,
                            ),
                            tooltip: 'Hapus Pekerjaan',
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                            onPressed: () => _handleDeleteTask(task),
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
