import 'package:flutter/material.dart';
import 'package:kita_kerja/controllers/auth_controller.dart';
import 'package:kita_kerja/controllers/task_controller.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/models/task_model.dart';
import 'package:kita_kerja/widgets/neo_components.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class PekerjaanScreen extends StatefulWidget {
  const PekerjaanScreen({super.key});

  @override
  State<PekerjaanScreen> createState() => _PekerjaanScreenState();
}

class _PekerjaanScreenState extends State<PekerjaanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthController>(context, listen: false);
      Provider.of<TaskController>(context, listen: false).loadTasks(auth.currentUser);
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

  void _handleQuickStatusDialog(TaskModel task, TaskController controller, AuthController auth) {
    final currentStatus = task.status;
    final isEmployee = auth.isEmployee;

    // Karyawan can only set to not_started, in_progress, or review (manager reviews to complete)
    final options = isEmployee
        ? [
            {'val': 'not_started', 'label': 'Belum Mulai', 'color': Colors.grey},
            {'val': 'in_progress', 'label': 'Sedang Dikerjakan', 'color': Utils.primary},
            {'val': 'review', 'label': 'Minta Review (Ditinjau)', 'color': Utils.secondary},
          ]
        : [
            {'val': 'not_started', 'label': 'Belum Mulai', 'color': Colors.grey},
            {'val': 'in_progress', 'label': 'Sedang Dikerjakan', 'color': Utils.primary},
            {'val': 'review', 'label': 'Ditinjau (Review)', 'color': Utils.secondary},
            {'val': 'completed', 'label': 'Selesai (Completed)', 'color': Utils.success},
          ];

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
            'Ubah Status Pekerjaan',
            style: TextStyle(fontWeight: FontWeight.w800, color: Utils.border),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tugas: "${task.title}"',
                style: const TextStyle(fontWeight: FontWeight.w700, color: Utils.border),
              ),
              const SizedBox(height: 16),
              ...options.map((opt) {
                final isSelected = opt['val'] == currentStatus;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      Navigator.pop(dialogContext);
                      final newVal = opt['val'] as String;
                      if (newVal != currentStatus) {
                        final ok = await controller.updateTaskStatus(
                          taskId: task.id,
                          status: newVal,
                          currentUser: auth.currentUser,
                          notes: isEmployee ? 'Update progres oleh ${auth.currentUser?.name}' : null,
                        );
                        if (ok && mounted) {
                          Utils.toast(
                            context,
                            'Status tugas diubah menjadi ${opt['label']}',
                            ToastificationType.success,
                            Icons.check,
                            Utils.success,
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF5F1E8) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Utils.border : const Color(0xFFE0E0E0),
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
                              border: Border.all(color: Utils.border, width: 1.5),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              opt['label'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: Utils.border,
                              ),
                            ),
                          ),
                          if (isSelected) const Icon(Icons.check_circle, color: Utils.primary, size: 18),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Tutup', style: TextStyle(color: Utils.border)),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteTask(TaskModel task, TaskController controller, AuthController auth) {
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
            'Apakah Anda yakin ingin menghapus pekerjaan "${task.title}"?\nTindakan ini tidak dapat dibatalkan.',
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
                final ok = await controller.deleteTask(task.id, auth.currentUser);
                if (ok && mounted) {
                  Utils.toast(
                    context,
                    'Pekerjaan "${task.title}" berhasil dihapus',
                    ToastificationType.success,
                    Icons.delete_outline,
                    Utils.danger,
                  );
                }
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

  Widget _buildEmployeeMetricsHeader(TaskController controller) {
    final m = controller.summaryMetrics;
    return Row(
      children: [
        _buildMetricCard('TUGAS AKTIF', '${m['total_active'] ?? 0}', Utils.primary, Icons.assignment),
        const SizedBox(width: 14),
        _buildMetricCard('BELUM MULAI', '${m['not_started_count'] ?? 0}', Colors.grey, Icons.pending_actions),
        const SizedBox(width: 14),
        _buildMetricCard('SEDANG DIKERJAKAN', '${m['in_progress_count'] ?? 0}', Utils.secondary, Icons.run_circle_outlined),
        const SizedBox(width: 14),
        _buildMetricCard('MENUNGGU REVIEW', '${m['review_count'] ?? 0}', const Color(0xFFF59E0B), Icons.rate_review_outlined),
        const SizedBox(width: 14),
        _buildMetricCard('SELESAI', '${m['completed_count'] ?? 0}', Utils.success, Icons.check_circle_outline),
      ],
    );
  }

  Widget _buildMetricCard(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Utils.border, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Utils.border,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Utils.border, width: 1.5),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF666666)),
                  ),
                  Text(
                    count,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Utils.border),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final isEmployee = auth.isEmployee;

    return Consumer<TaskController>(
      builder: (context, controller, child) {
        final filtered = controller.filteredTasks;

        return MainLayout(
          title: isEmployee ? 'Tugas Saya' : 'Manajemen Pekerjaan',
          activeMenu: 'pekerjaan',
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // If Karyawan, show summary metrics banner
                if (isEmployee) ...[
                  _buildEmployeeMetricsHeader(controller),
                  const SizedBox(height: 20),
                ],

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
                                onChanged: (val) => controller.setSearchQuery(val),
                                decoration: InputDecoration(
                                  hintText: isEmployee
                                      ? 'Cari judul tugas atau kategori saya...'
                                      : 'Cari judul tugas, penanggung jawab, atau kategori...',
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
                          value: controller.selectedStatus,
                          icon: const Icon(Icons.arrow_drop_down, color: Utils.border),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Utils.border),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('Semua Status')),
                            DropdownMenuItem(value: 'not_started', child: Text('Belum Mulai')),
                            DropdownMenuItem(value: 'in_progress', child: Text('Sedang Dikerjakan')),
                            DropdownMenuItem(value: 'review', child: Text('Ditinjau')),
                            DropdownMenuItem(value: 'completed', child: Text('Selesai')),
                          ],
                          onChanged: (val) {
                            if (val != null) controller.setSelectedStatus(val);
                          },
                        ),
                      ),
                    ),
                    // Only Admin and Manager can add tasks
                    if (!isEmployee) ...[
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 200,
                        height: 42,
                        child: NeoButton(
                          text: '+ Tambah Pekerjaan',
                          backgroundColor: Utils.primary,
                          onPressed: () async {
                            final result = await Navigator.pushNamed(context, '/pekerjaan-form');
                            if (result == true && mounted) {
                              controller.loadTasks(auth.currentUser);
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),

                // Tasks Table
                NeoTable(
                  isLoading: controller.isLoading,
                  emptyIcon: Icons.assignment_turned_in_outlined,
                  emptyText: isEmployee ? 'Tidak ada pekerjaan yang ditugaskan kepada Anda' : 'Tidak ada data pekerjaan ditemukan',
                  columnWidths: isEmployee
                      ? const {
                          0: FlexColumnWidth(2.5),
                          1: FlexColumnWidth(1.2),
                          2: FlexColumnWidth(1.0),
                          3: FlexColumnWidth(1.4),
                          4: FlexColumnWidth(1.2),
                          5: FlexColumnWidth(1.2),
                        }
                      : const {
                          0: FlexColumnWidth(2.2),
                          1: FlexColumnWidth(1.5),
                          2: FlexColumnWidth(1.1),
                          3: FlexColumnWidth(1.0),
                          4: FlexColumnWidth(1.3),
                          5: FlexColumnWidth(1.1),
                          6: FlexColumnWidth(1.5),
                        },
                  headers: isEmployee
                      ? const [
                          NeoTableHeaderCell('JUDUL PEKERJAAN'),
                          NeoTableHeaderCell('KATEGORI'),
                          NeoTableHeaderCell('PRIORITAS'),
                          NeoTableHeaderCell('STATUS'),
                          NeoTableHeaderCell('DEADLINE'),
                          NeoTableHeaderCell('AKSI'),
                        ]
                      : const [
                          NeoTableHeaderCell('JUDUL PEKERJAAN'),
                          NeoTableHeaderCell('PENANGGUNG JAWAB'),
                          NeoTableHeaderCell('KATEGORI'),
                          NeoTableHeaderCell('PRIORITAS'),
                          NeoTableHeaderCell('STATUS'),
                          NeoTableHeaderCell('DEADLINE'),
                          NeoTableHeaderCell('AKSI'),
                        ],
                  rows: filtered.map((task) {
                    final rowCells = <NeoTableCell>[];

                    // Title & Description
                    rowCells.add(
                      NeoTableCell(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Utils.border),
                            ),
                            if (task.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                task.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );

                    // Assigned To (only for admin/manager)
                    if (!isEmployee) {
                      rowCells.add(
                        NeoTableCell(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.assignedToName,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Utils.border),
                              ),
                              if (task.employeeCode.isNotEmpty)
                                Text(
                                  task.employeeCode,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
                                ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Category
                    rowCells.add(NeoTableCell(text: task.categoryName));

                    // Priority Badge
                    rowCells.add(
                      NeoTableCell(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getPriorityBg(task.priority),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Utils.border, width: 1.5),
                            ),
                            child: Text(
                              task.priorityLabel,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _getPriorityText(task.priority)),
                            ),
                          ),
                        ),
                      ),
                    );

                    // Status Badge (Clickable to change status)
                    rowCells.add(
                      NeoTableCell(
                        child: Align(
                          alignment: Alignment.center,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => _handleQuickStatusDialog(task, controller, auth),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _getStatusBg(task.status),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Utils.border, width: 1.5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      task.statusLabel,
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _getStatusText(task.status)),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.edit_note, size: 14, color: _getStatusText(task.status)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                    // Deadline
                    rowCells.add(NeoTableCell(text: task.deadline));

                    // Actions
                    if (isEmployee) {
                      // Karyawan only has update status button
                      rowCells.add(
                        NeoTableCell(
                          child: Align(
                            alignment: Alignment.center,
                            child: OutlinedButton.icon(
                              onPressed: () => _handleQuickStatusDialog(task, controller, auth),
                              icon: const Icon(Icons.sync, size: 14, color: Utils.primary),
                              label: const Text('Update Progres', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Utils.primary)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Utils.primary, width: 1.5),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Admin / Manager has full edit and delete
                      rowCells.add(
                        NeoTableCell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Utils.primary, size: 18),
                                tooltip: 'Edit Detail',
                                onPressed: () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    '/pekerjaan-form',
                                    arguments: task.toMap(),
                                  );
                                  if (result == true && mounted) {
                                    controller.loadTasks(auth.currentUser);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Utils.danger, size: 18),
                                tooltip: 'Hapus Pekerjaan',
                                onPressed: () => _handleDeleteTask(task, controller, auth),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return rowCells;
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
