import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/controllers/auth_controller.dart';
import 'package:kita_kerja/controllers/task_controller.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/models/task_model.dart';
import 'package:kita_kerja/models/task_progress_model.dart';
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
    _showTaskProgressDetailDialog(task, controller, auth);
  }

  void _showTaskProgressDetailDialog(
    TaskModel task,
    TaskController controller,
    AuthController auth,
  ) {
    final isEmployee = auth.isEmployee;
    String selectedStatus = task.status;
    double currentPercentage = task.progressPercentage.toDouble();
    final notesController = TextEditingController();
    final hoursController = TextEditingController(
      text: task.actualHours > 0 ? task.actualHours.toString() : '',
    );
    bool isSaving = false;
    Future<List<TaskProgressModel>> progressFuture =
        controller.getTaskProgress(task.id);

    final statusOptions = isEmployee
        ? const [
            {'val': 'not_started', 'label': 'Belum Mulai'},
            {'val': 'in_progress', 'label': 'Sedang Dikerjakan'},
            {'val': 'review', 'label': 'Minta Review (Ditinjau)'},
          ]
        : const [
            {'val': 'not_started', 'label': 'Belum Mulai'},
            {'val': 'in_progress', 'label': 'Sedang Dikerjakan'},
            {'val': 'review', 'label': 'Ditinjau (Review)'},
            {'val': 'completed', 'label': 'Selesai (Completed)'},
          ];

    NeoDialog.show(
      context: context,
      title: 'Riwayat & Progres Pekerjaan',
      maxWidth: 680,
      content: StatefulBuilder(
        builder: (ctx, setDialogState) {
          return SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Task Header Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Utils.neoCream,
                      border: Utils.borderW,
                      boxShadow: Utils.shadowSm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.neoBlack,
                                    ),
                                  ),
                                  if (task.description.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      task.description,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: Utils.neoBlack,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            NeoBadge.taskStatus(task.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            NeoTag(label: task.categoryName),
                            NeoBadge.taskPriority(task.priority),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                NeoAvatar(name: task.assignedToName, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  '${task.assignedToName} (${task.employeeCode})',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Utils.neoBlack,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: Utils.neoBlack),
                                const SizedBox(width: 4),
                                Text(
                                  'Deadline: ${task.deadline}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Utils.neoBlack,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_outlined, size: 14, color: Utils.neoBlack),
                                const SizedBox(width: 4),
                                Text(
                                  'Est: ${task.estimatedHours}j • Akt: ${task.actualHours}j',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Utils.neoBlack,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Indikator Progres Visual Saat Ini
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progres Terkini',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Utils.neoBlack,
                              ),
                            ),
                            Text(
                              '${task.progressPercentage}%',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Utils.neoBlack,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Utils.borderWSm,
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (task.progressPercentage / 100.0).clamp(0.0, 1.0),
                            child: Container(
                              color: task.status == 'completed'
                                  ? Utils.neoGreen
                                  : (task.status == 'review'
                                      ? Utils.neoYellow
                                      : Utils.neoBlue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Aksi Cepat Persetujuan bagi Admin / Manager jika tugas berstatus 'review'
                  if (!isEmployee && task.status == 'review') ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Utils.neoYellow,
                        border: Utils.borderW,
                        boxShadow: Utils.shadowSm,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Utils.neoBlack, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tugas sedang dalam tinjauan tim. Anda dapat meninjau log di bawah lalu menyetujui:',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Utils.neoBlack,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          NeoButton(
                            text: 'Setujui (100%)',
                            variant: NeoButtonVariant.success,
                            size: NeoButtonSize.sm,
                            icon: const Icon(Icons.check_circle_outline, size: 16),
                            onPressed: () async {
                              Navigator.pop(context);
                              final ok = await controller.recordTaskProgress(
                                taskId: task.id,
                                employeeId: auth.currentUser?.employeeId ?? task.assignedTo,
                                status: 'completed',
                                progressPercentage: 100,
                                notes: 'Disetujui dan diselesaikan oleh ${auth.currentUser?.name}',
                                currentUser: auth.currentUser,
                                taskTitle: task.title,
                              );
                              if (ok && mounted) {
                                Utils.toast(
                                  context,
                                  'Tugas "${task.title}" berhasil disetujui & diselesaikan!',
                                  ToastificationType.success,
                                  Icons.check,
                                  Utils.neoGreen,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 2. TIMELINE RIWAYAT PROGRES (PRD Sec 6.5 & Tabel 12)
                  Row(
                    children: [
                      const Icon(Icons.timeline, size: 20, color: Utils.neoBlack),
                      const SizedBox(width: 8),
                      Text(
                        'TIMELINE RIWAYAT PROGRES',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Utils.neoBlack,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<TaskProgressModel>>(
                    future: progressFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Utils.neoBlack),
                            ),
                          ),
                        );
                      }
                      final logs = snapshot.data ?? [];
                      if (logs.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Utils.neoCream,
                            border: Utils.borderWSm,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.history_toggle_off, size: 24, color: Utils.neoBlack),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Belum ada catatan log riwayat progres untuk pekerjaan ini.',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Utils.neoBlack,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: logs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, idx) {
                          final log = logs[idx];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Utils.neoCream,
                              border: Utils.borderWSm,
                              boxShadow: Utils.shadowSm,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: const BoxDecoration(
                                        color: Utils.neoBlack,
                                      ),
                                      child: Text(
                                        '${log.progressPercentage}%',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Utils.neoCream,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    NeoBadge.taskStatus(log.status),
                                    const Spacer(),
                                    Text(
                                      log.recordedAt.length >= 16
                                          ? log.recordedAt.substring(0, 16)
                                          : log.recordedAt,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Utils.neoBlack,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  log.notes,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Utils.neoBlack,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 14, color: Utils.neoBlack),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Dicatat oleh: ${log.employeeName ?? "Karyawan"} ${log.employeeCode != null ? "(${log.employeeCode})" : ""}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Utils.neoBlack.withOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Utils.neoBlack, thickness: 1.5),
                  const SizedBox(height: 14),

                  // 3. FORM CATAT PROGRES AKTUAL (Input 0% - 100% & Catatan Singkat)
                  Row(
                    children: [
                      const Icon(Icons.edit_note, size: 20, color: Utils.neoBlack),
                      const SizedBox(width: 8),
                      Text(
                        'CATAT PROGRES AKTUAL',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Utils.neoBlack,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Pilihan Status
                  Text(
                    'STATUS PROGRES PEKERJAAN',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Utils.neoBlack,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: const BoxDecoration(
                      color: Utils.neoCream,
                      border: Utils.borderW,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedStatus,
                        isExpanded: true,
                        dropdownColor: Utils.neoCream,
                        items: statusOptions.map((opt) {
                          return DropdownMenuItem<String>(
                            value: opt['val'],
                            child: Text(
                              opt['label']!,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Utils.neoBlack,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedStatus = val;
                              if (val == 'completed') {
                                currentPercentage = 100;
                              } else if (val == 'review' && currentPercentage < 80) {
                                currentPercentage = 90;
                              } else if (val == 'in_progress' && currentPercentage == 0) {
                                currentPercentage = 25;
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Input Persentase Progres Aktual (0% - 100%) dengan Slider & Preset
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PERSENTASE PROGRES AKTUAL',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Utils.neoBlack,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: const BoxDecoration(
                          color: Utils.neoBlack,
                        ),
                        child: Text(
                          '${currentPercentage.toInt()}%',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Utils.neoCream,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Utils.neoBlack,
                      inactiveTrackColor: Colors.grey.shade400,
                      thumbColor: Utils.neoYellow,
                      overlayColor: Utils.neoYellow.withOpacity(0.3),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: currentPercentage,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      onChanged: (val) {
                        setDialogState(() {
                          currentPercentage = val;
                          if (currentPercentage == 100 && !isEmployee) {
                            selectedStatus = 'completed';
                          } else if (currentPercentage >= 90 && isEmployee) {
                            selectedStatus = 'review';
                          } else if (currentPercentage > 0 && selectedStatus == 'not_started') {
                            selectedStatus = 'in_progress';
                          }
                        });
                      },
                    ),
                  ),

                  // Preset chips (25%, 50%, 75%, 100%)
                  Row(
                    children: [
                      const Text(
                        'Preset Cepat: ',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      ...[25, 50, 75, 100].map((pct) {
                        final isSel = currentPercentage.toInt() == pct;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  currentPercentage = pct.toDouble();
                                  if (pct == 100 && !isEmployee) {
                                    selectedStatus = 'completed';
                                  } else if (pct >= 90 && isEmployee) {
                                    selectedStatus = 'review';
                                  } else if (pct > 0 && selectedStatus == 'not_started') {
                                    selectedStatus = 'in_progress';
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSel ? Utils.neoYellow : Utils.neoCream,
                                  border: Utils.borderWSm,
                                  boxShadow: isSel ? Utils.shadowSm : null,
                                ),
                                child: Text(
                                  '$pct%',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Utils.neoBlack,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Input Catatan / Log Progres Singkat
                  NeoTextField(
                    label: 'Catatan Log Progres Singkat',
                    placeholder: 'Misal: Selesai merapikan layout, lanjut styling tombol',
                    controller: notesController,
                  ),

                  const SizedBox(height: 12),

                  // Input Jam Aktual (Opsional)
                  NeoTextField(
                    label: 'Jam Pengerjaan Aktual (Opsional)',
                    placeholder: 'Contoh: 4.5',
                    controller: hoursController,
                  ),
                ],
              ),
            ),
          );
        },
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
          text: 'Simpan Progres',
          variant: NeoButtonVariant.primary,
          size: NeoButtonSize.sm,
          isLoading: isSaving,
          onPressed: () async {
            final pct = currentPercentage.toInt();
            final notes = notesController.text.trim();
            final actualHours = double.tryParse(hoursController.text.trim());

            Navigator.pop(context);

            final ok = await controller.recordTaskProgress(
              taskId: task.id,
              employeeId: auth.currentUser?.employeeId ?? task.assignedTo,
              status: selectedStatus,
              progressPercentage: pct,
              notes: notes.isNotEmpty
                  ? notes
                  : 'Update progres $pct% (${selectedStatus.replaceAll('_', ' ')})',
              actualHours: actualHours,
              currentUser: auth.currentUser,
              taskTitle: task.title,
            );

            if (!mounted) return;
            if (ok) {
              Utils.toast(
                context,
                'Log progres pekerjaan berhasil dicatat!',
                ToastificationType.success,
                Icons.check,
                Utils.neoGreen,
              );
            } else {
              Utils.toast(
                context,
                'Gagal mencatat progres pekerjaan',
                ToastificationType.error,
                Icons.close,
                Utils.neoRed,
              );
            }
          },
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
                const SizedBox(height: 8),
                // Progress Bar & Percentage
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Utils.borderWSm,
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (task.progressPercentage / 100.0).clamp(0.0, 1.0),
                          child: Container(
                            color: task.status == 'completed'
                                ? Utils.neoGreen
                                : (task.status == 'review'
                                    ? Utils.neoYellow
                                    : Utils.neoBlue),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${task.progressPercentage}%',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Utils.neoBlack,
                      ),
                    ),
                  ],
                ),
                if (task.latestNotes != null && task.latestNotes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Log: ${task.latestNotes}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Utils.neoBlack.withOpacity(0.7),
                    ),
                  ),
                ],
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
                              0: FlexColumnWidth(2.2),
                              1: FlexColumnWidth(1.2),
                              2: FlexColumnWidth(1.0),
                              3: FlexColumnWidth(1.4),
                              4: FlexColumnWidth(1.3),
                              5: FlexColumnWidth(1.1),
                              6: FlexColumnWidth(1.1),
                            }
                          : const {
                              0: FlexColumnWidth(1.8),
                              1: FlexColumnWidth(1.3),
                              2: FlexColumnWidth(1.0),
                              3: FlexColumnWidth(1.0),
                              4: FlexColumnWidth(1.3),
                              5: FlexColumnWidth(1.2),
                              6: FlexColumnWidth(1.1),
                              7: FlexColumnWidth(1.3),
                            },
                      headers: isEmployee
                          ? const [
                              NeoTableHeaderCell('JUDUL PEKERJAAN'),
                              NeoTableHeaderCell('KATEGORI'),
                              NeoTableHeaderCell('PRIORITAS'),
                              NeoTableHeaderCell('STATUS'),
                              NeoTableHeaderCell('PROGRES'),
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
                              NeoTableHeaderCell('PROGRES'),
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
                                onTap: () => _showTaskProgressDetailDialog(
                                  task,
                                  controller,
                                  auth,
                                ),
                                child: NeoBadge.taskStatus(task.status),
                              ),
                            ),
                          ),
                        );

                        // Progres Bar Mini & Persentase
                        rowCells.add(
                          NeoTableCell(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => _showTaskProgressDetailDialog(
                                  task,
                                  controller,
                                  auth,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        border: Utils.borderWSm,
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: (task.progressPercentage / 100.0).clamp(0.0, 1.0),
                                        child: Container(
                                          color: task.status == 'completed'
                                              ? Utils.neoGreen
                                              : (task.status == 'review'
                                                  ? Utils.neoYellow
                                                  : Utils.neoBlue),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${task.progressPercentage}%',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Utils.neoBlack,
                                      ),
                                    ),
                                  ],
                                ),
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
                                text: 'Progres',
                                size: NeoButtonSize.sm,
                                variant: NeoButtonVariant.primary,
                                icon: const Icon(Icons.edit_note, size: 16),
                                onPressed: () => _showTaskProgressDetailDialog(
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
                                    icon: Icons.timeline,
                                    size: 32,
                                    tooltip: 'Riwayat Progres',
                                    onPressed: () => _showTaskProgressDetailDialog(
                                      task,
                                      controller,
                                      auth,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
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
