import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  int _currentTab = 0; // 0: Daftar, 1: Papan (Kanban), 2: Beban Kerja

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthController>(context, listen: false);
      Provider.of<TaskController>(
        context,
        listen: false,
      ).loadTasks(auth.currentUser);
    });
  }

  void _handleQuickStatusDialog(
    TaskModel task,
    TaskController controller,
    AuthController auth,
  ) {
    final currentStatus = task.status;
    final isEmployee = auth.isEmployee;

    final options = isEmployee
        ? [
            {'val': 'not_started', 'label': 'Belum Mulai'},
            {'val': 'in_progress', 'label': 'Sedang Dikerjakan'},
            {'val': 'review', 'label': 'Minta Review (Ditinjau)'},
          ]
        : [
            {'val': 'not_started', 'label': 'Belum Mulai'},
            {'val': 'in_progress', 'label': 'Sedang Dikerjakan'},
            {'val': 'review', 'label': 'Ditinjau (Review)'},
            {'val': 'completed', 'label': 'Selesai (Completed)'},
          ];

    NeoDialog.show(
      context: context,
      title: 'Perbarui Status Progres',
      maxWidth: 480,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tugas: "${task.title}"',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: Utils.neoBlack,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((opt) {
            final isSelected = opt['val'] == currentStatus;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    final newVal = opt['val'] as String;
                    if (newVal != currentStatus) {
                      final ok = await controller.updateTaskStatus(
                        taskId: task.id,
                        status: newVal,
                        currentUser: auth.currentUser,
                        notes: isEmployee
                            ? 'Update progres oleh ${auth.currentUser?.name}'
                            : null,
                      );
                      if (ok && mounted) {
                        Utils.toast(
                          context,
                          'Status tugas berhasil diubah!',
                          ToastificationType.success,
                          Icons.check,
                          Utils.neoGreen,
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Utils.neoYellow : Utils.neoCream,
                      borderRadius: BorderRadius.zero,
                      border: Utils.borderW,
                      boxShadow: isSelected ? Utils.shadowMd : Utils.shadowSm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          opt['label'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Utils.neoBlack,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check,
                            color: Utils.neoBlack,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
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

  void _handleDeleteTask(
    TaskModel task,
    TaskController controller,
    AuthController auth,
  ) {
    NeoDialog.show(
      context: context,
      title: 'Hapus Pekerjaan?',
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
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Utils.neoBlack,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Pekerjaan "${task.title}" akan dihapus permanen. Data riwayat pengerjaan tidak dapat dikembalikan.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Utils.neoBlack,
                height: 1.4,
              ),
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
          text: 'Hapus',
          variant: NeoButtonVariant.danger,
          size: NeoButtonSize.sm,
          onPressed: () async {
            Navigator.pop(context);
            final ok = await controller.deleteTask(task.id, auth.currentUser);
            if (ok && mounted) {
              Utils.toast(
                context,
                'Pekerjaan "${task.title}" berhasil dihapus',
                ToastificationType.success,
                Icons.delete,
                Utils.neoGreen,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildKanbanBoard(
    List<TaskModel> tasks,
    TaskController controller,
    AuthController auth,
  ) {
    const columns = [
      {'status': 'not_started', 'label': 'BELUM MULAI'},
      {'status': 'in_progress', 'label': 'SEDANG DIKERJAKAN'},
      {'status': 'review', 'label': 'DITINJAU'},
      {'status': 'completed', 'label': 'SELESAI'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris 1: Belum Mulai & Sedang Dikerjakan (2 kolom per baris)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildKanbanColumn(columns[0], tasks, controller, auth)),
            const SizedBox(width: 20),
            Expanded(child: _buildKanbanColumn(columns[1], tasks, controller, auth)),
          ],
        ),
        const SizedBox(height: 24),
        // Baris 2: Ditinjau & Selesai (2 kolom per baris)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildKanbanColumn(columns[2], tasks, controller, auth)),
            const SizedBox(width: 20),
            Expanded(child: _buildKanbanColumn(columns[3], tasks, controller, auth)),
          ],
        ),
      ],
    );
  }

  Widget _buildKanbanColumn(
    Map<String, String> col,
    List<TaskModel> tasks,
    TaskController controller,
    AuthController auth,
  ) {
    final colStatus = col['status']!;
    final colLabel = col['label']!;
    final colTasks = tasks
        .where((t) => t.status.toLowerCase() == colStatus)
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: Utils.neoCream,
        border: Utils.borderW,
        boxShadow: Utils.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column Header: Fill Neo Black, text Neo Cream, count tag
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            color: Utils.neoBlack,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  colLabel,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Utils.neoCream,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: const BoxDecoration(color: Utils.neoCream),
                  child: Text(
                    '${colTasks.length}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Utils.neoBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Column Job Cards
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 220),
            child: colTasks.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(
                      child: Text(
                        'Belum ada pekerjaan',
                        style: TextStyle(
                          color: Utils.neoBlack,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(14),
                    itemCount: colTasks.length,
                    itemBuilder: (context, idx) {
                      final task = colTasks[idx];
                      return _buildJobCard(task, controller, auth);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    TaskModel task,
    TaskController controller,
    AuthController auth,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _handleQuickStatusDialog(task, controller, auth),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Utils.neoCream,
              borderRadius: BorderRadius.zero,
              border: Utils.borderW,
              boxShadow: Utils.shadowMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Utils.neoBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    NeoTag(label: task.categoryName),
                    NeoBadge.taskPriority(task.priority),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          NeoAvatar(name: task.assignedToName, size: 20),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              task.assignedToName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Utils.neoBlack,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      task.deadline,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Utils.neoBlack,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkloadTab(List<TaskModel> tasks, AuthController auth) {
    // Group tasks per employee and show workload meters
    final empTasksMap = <String, List<TaskModel>>{};
    for (var t in tasks) {
      empTasksMap.putIfAbsent(t.assignedToName, () => []).add(t);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            NeoKPICard(
              title: 'TOTAL PEKERJAAN',
              value: '${tasks.length}',
              caption: 'Semua pekerjaan terdaftar',
              icon: Icons.assignment,
              iconContainerColor: Utils.neoBlack,
              iconColor: Utils.neoCream,
            ),
            const SizedBox(width: 16),
            NeoKPICard(
              title: 'SEDANG BERJALAN',
              value: '${tasks.where((t) => t.status == 'in_progress').length}',
              caption: 'Dalam proses pengerjaan',
              icon: Icons.play_arrow,
              iconContainerColor: Utils.neoBlue,
              iconColor: Utils.neoCream,
            ),
            const SizedBox(width: 16),
            NeoKPICard(
              title: 'MENUNGGU TINJAUAN',
              value: '${tasks.where((t) => t.status == 'review').length}',
              caption: 'Siap diperiksa supervisor',
              icon: Icons.remove_red_eye,
              iconContainerColor: Utils.neoYellow,
              iconColor: Utils.neoBlack,
            ),
          ],
        ),
        const SizedBox(height: 24),
        NeoContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BEBAN PENUGASAN KARYAWAN',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Utils.neoBlack,
                ),
              ),
              const SizedBox(height: 20),
              if (empTasksMap.isEmpty) ...[
                const Center(child: Text('Belum ada pembagian tugas.')),
              ] else ...[
                ...empTasksMap.entries.map((entry) {
                  final empName = entry.key;
                  final count = entry.value.length;
                  // Approx 8 hours capacity basis
                  final pct = (count * 25.0);
                  return NeoWorkloadMeter(
                    percentage: pct,
                    label: empName,
                    detailText: '$count tugas aktif ditugaskan',
                  );
                }),
              ],
            ],
          ),
        ),
      ],
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Level Tabs: DAFTAR · PAPAN · BEBAN KERJA (Section 8.5)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NeoTabs(
                        tabs: const ['DAFTAR', 'PAPAN', 'BEBAN KERJA'],
                        selectedIndex: _currentTab,
                        onTabSelected: (idx) =>
                            setState(() => _currentTab = idx),
                      ),
                      if (!isEmployee)
                        NeoButton(
                          text: '+ Buat Pekerjaan',
                          variant: NeoButtonVariant.primary,
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/pekerjaan-form',
                            );
                            if (result == true && mounted) {
                              controller.loadTasks(auth.currentUser);
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Filter & Search Controls (for Daftar and Papan)
                  if (_currentTab != 2) ...[
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
                                const Icon(
                                  Icons.search,
                                  color: Utils.neoBlack,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    onChanged: (val) =>
                                        controller.setSearchQuery(val),
                                    decoration: InputDecoration(
                                      hintText: isEmployee
                                          ? 'Cari judul tugas atau kategori saya...'
                                          : 'Cari judul tugas, penanggung jawab, atau kategori...',
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      isDense: true,
                                    ),
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Utils.neoBlack,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Status Filter Dropdown
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
                            child: DropdownButton<String>(
                              value: controller.selectedStatus,
                              dropdownColor: Utils.neoCream,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Utils.neoBlack,
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Utils.neoBlack,
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
                                if (val != null) {
                                  controller.setSelectedStatus(val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Tab Content Rendering
                  if (_currentTab == 0) ...[
                    // 1. Mode DAFTAR (Tabel Single-Frame)
                    NeoTable(
                      isLoading: controller.isLoading,
                      emptyIcon: Icons.assignment_outlined,
                      emptyText: 'Tidak ada pekerjaan ditemukan',
                      columnWidths: isEmployee
                          ? const {
                              0: FlexColumnWidth(2.3),
                              1: FlexColumnWidth(1.2),
                              2: FlexColumnWidth(1.2),
                              3: FlexColumnWidth(1.5),
                              4: FlexColumnWidth(1.2),
                              5: FlexColumnWidth(1.0),
                            }
                          : const {
                              0: FlexColumnWidth(2.0),
                              1: FlexColumnWidth(1.4),
                              2: FlexColumnWidth(1.1),
                              3: FlexColumnWidth(1.2),
                              4: FlexColumnWidth(1.6),
                              5: FlexColumnWidth(1.1),
                              6: FlexColumnWidth(0.9),
                            },
                      headers: isEmployee
                          ? const [
                              NeoTableHeaderCell('JUDUL PEKERJAAN'),
                              NeoTableHeaderCell('KATEGORI'),
                              NeoTableHeaderCell('PRIORITAS'),
                              NeoTableHeaderCell('STATUS'),
                              NeoTableHeaderCell('DEADLINE'),
                              NeoTableHeaderCell(
                                'AKSI',
                                alignment: Alignment.center,
                              ),
                            ]
                          : const [
                              NeoTableHeaderCell('JUDUL PEKERJAAN'),
                              NeoTableHeaderCell('PENANGGUNG JAWAB'),
                              NeoTableHeaderCell('KATEGORI'),
                              NeoTableHeaderCell('PRIORITAS'),
                              NeoTableHeaderCell('STATUS'),
                              NeoTableHeaderCell('DEADLINE'),
                              NeoTableHeaderCell(
                                'AKSI',
                                alignment: Alignment.center,
                              ),
                            ],
                      rows: filtered.map((task) {
                        final rowCells = <NeoTableCell>[];

                        // Judul
                        rowCells.add(
                          NeoTableCell(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Utils.neoBlack,
                                  ),
                                ),
                                if (task.description.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    task.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: Utils.neoBlack,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );

                        // Penanggung Jawab (admin/manager)
                        if (!isEmployee) {
                          rowCells.add(
                            NeoTableCell(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  NeoAvatar(
                                    name: task.assignedToName,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      task.assignedToName,
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
                          );
                        }

                        // Kategori Tag
                        rowCells.add(
                          NeoTableCell(child: NeoTag(label: task.categoryName)),
                        );

                        // Prioritas Badge
                        rowCells.add(
                          NeoTableCell(
                            child: NeoBadge.taskPriority(task.priority),
                          ),
                        );

                        // Status Badge (Clickable)
                        rowCells.add(
                          NeoTableCell(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => _handleQuickStatusDialog(
                                  task,
                                  controller,
                                  auth,
                                ),
                                child: NeoBadge.taskStatus(task.status),
                              ),
                            ),
                          ),
                        );

                        // Deadline
                        rowCells.add(NeoTableCell(text: task.deadline));

                        // Aksi
                        if (isEmployee) {
                          rowCells.add(
                            NeoTableCell(
                              alignment: Alignment.center,
                              child: NeoButton(
                                text: 'Update',
                                size: NeoButtonSize.sm,
                                variant: NeoButtonVariant.neutral,
                                onPressed: () => _handleQuickStatusDialog(
                                  task,
                                  controller,
                                  auth,
                                ),
                              ),
                            ),
                          );
                        } else {
                          rowCells.add(
                            NeoTableCell(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  NeoIconButton(
                                    icon: Icons.edit,
                                    size: 32,
                                    tooltip: 'Ubah',
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
                                  const SizedBox(width: 6),
                                  NeoIconButton(
                                    icon: Icons.delete,
                                    size: 32,
                                    iconColor: Utils.neoRed,
                                    tooltip: 'Hapus',
                                    onPressed: () => _handleDeleteTask(
                                      task,
                                      controller,
                                      auth,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return rowCells;
                      }).toList(),
                    ),
                  ] else if (_currentTab == 1) ...[
                    // 2. Mode PAPAN KANBAN (Section 7.5)
                    _buildKanbanBoard(filtered, controller, auth),
                  ] else ...[
                    // 3. Mode BEBAN KERJA (Section 7.3 & 8.5)
                    _buildWorkloadTab(filtered, auth),
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
