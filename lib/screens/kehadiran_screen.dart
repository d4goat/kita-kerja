import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/controllers/attendance_controller.dart';
import 'package:kita_kerja/models/attendance_model.dart';
import 'package:kita_kerja/controllers/auth_controller.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/widgets/neo_components.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class KehadiranScreen extends StatefulWidget {
  const KehadiranScreen({super.key});

  @override
  State<KehadiranScreen> createState() => _KehadiranScreenState();
}

class _KehadiranScreenState extends State<KehadiranScreen> {
  final TextEditingController _notesController = TextEditingController();
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthController>(context, listen: false);
      Provider.of<AttendanceController>(context, listen: false).loadAttendances(auth.currentUser);
    });

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  String _formatCurrentTime() {
    final h = _currentTime.hour.toString().padLeft(2, '0');
    final m = _currentTime.minute.toString().padLeft(2, '0');
    final s = _currentTime.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatTodayDate() {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    final dayName = days[_currentTime.weekday % 7];
    final monthName = months[_currentTime.month];
    return '$dayName, ${_currentTime.day} $monthName ${_currentTime.year}';
  }

  // Section 7.4 Widget Absen (Asimetris 7/5)
  Widget _buildClockInOutCard(AttendanceController controller, AuthController auth) {
    final user = auth.currentUser;
    final today = controller.todayAttendance;
    final hasIn = controller.hasClockedInToday;
    final hasOut = controller.hasClockedOutToday;

    return NeoContainer(
      padding: const EdgeInsets.all(28),
      boxShadow: Utils.shadowLg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kiri 7/12: Jam live KPI, tanggal, jadwal kerja
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const NeoTag(label: 'PRESENSI HARI INI'),
                    const SizedBox(width: 10),
                    Text(
                      'Shift Pagi 08:00 – 17:00 WIB',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Utils.neoBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _formatCurrentTime(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Utils.neoBlack,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTodayDate(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Utils.neoBlack,
                  ),
                ),
                const SizedBox(height: 12),
                if (hasIn && !hasOut)
                  Row(
                    children: [
                      NeoBadge.attendance(today?.status ?? 'present'),
                      const SizedBox(width: 10),
                      Text(
                        'Masuk: ${today?.clockIn} WIB',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Utils.neoBlack,
                        ),
                      ),
                    ],
                  )
                else if (hasOut)
                  Row(
                    children: [
                      const NeoBadge(
                        label: 'SELESAI HARI INI',
                        icon: Icons.check,
                        backgroundColor: Utils.neoGreen,
                        foregroundColor: Utils.neoBlack,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Total Jam Kerja: ${today?.workingHoursFormatted ?? '8j'}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Utils.neoBlack,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Kanan 5/12: Tombol XL Sesuai State Absen (88px)
          Expanded(
            flex: 5,
            child: !hasIn
                ? NeoButton(
                    text: 'MASUK KERJA',
                    size: NeoButtonSize.xl,
                    variant: NeoButtonVariant.success,
                    icon: const Icon(Icons.login, size: 28),
                    isLoading: controller.isLoading,
                    isFullWidth: true,
                    onPressed: () async {
                      if (user == null) return;
                      final ok = await controller.clockIn(user);
                      if (ok && mounted) {
                        Utils.toast(
                          context,
                          'Masuk kerja tercatat pukul ${_formatCurrentTime()}',
                          ToastificationType.success,
                          Icons.check,
                          Utils.neoGreen,
                        );
                      }
                    },
                  )
                : (!hasOut
                    ? NeoButton(
                        text: 'PULANG KERJA',
                        size: NeoButtonSize.xl,
                        variant: NeoButtonVariant.secondary,
                        icon: const Icon(Icons.logout, size: 28),
                        isLoading: controller.isLoading,
                        isFullWidth: true,
                        onPressed: () async {
                          if (user == null) return;
                          final ok = await controller.clockOut(user);
                          if (ok && mounted) {
                            Utils.toast(
                              context,
                              'Pulang kerja tercatat pukul ${_formatCurrentTime()}',
                              ToastificationType.success,
                              Icons.check,
                              Utils.neoGreen,
                            );
                          }
                        },
                      )
                    : NeoButton(
                        text: 'SELESAI HARI INI',
                        size: NeoButtonSize.xl,
                        variant: NeoButtonVariant.neutral,
                        isFullWidth: true,
                        onPressed: null, // Disabled
                      )),
          ),
        ],
      ),
    );
  }

  void _showCorrectionDialog(
    AttendanceModel att,
    AuthController auth,
    AttendanceController controller,
  ) {
    final dateController = TextEditingController(text: att.attendanceDate);
    final inController = TextEditingController(text: att.clockIn == '-' ? '08:00' : att.clockIn);
    final outController = TextEditingController(text: att.clockOut == '-' ? '17:00' : att.clockOut);
    final notesController = TextEditingController(text: att.notes == '-' ? '' : att.notes);
    String status = att.status;

    NeoDialog.show(
      context: context,
      title: 'Koreksi Kehadiran',
      maxWidth: 520,
      content: StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeoAlert.info(text: 'Koreksi tercatat otomatis di Log Aktivitas sistem.'),
              const SizedBox(height: 16),
              NeoTextField(
                label: 'Tanggal (YYYY-MM-DD)',
                placeholder: '2026-11-16',
                controller: dateController,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: NeoTextField(
                      label: 'Jam Masuk (HH:mm)',
                      placeholder: '08:00',
                      controller: inController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoTextField(
                      label: 'Jam Keluar (HH:mm)',
                      placeholder: '17:00',
                      controller: outController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'STATUS KEHADIRAN',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Utils.neoBlack,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: const BoxDecoration(
                  color: Utils.neoCream,
                  borderRadius: BorderRadius.zero,
                  border: Utils.borderW,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: status,
                    isExpanded: true,
                    dropdownColor: Utils.neoCream,
                    items: const [
                      DropdownMenuItem(value: 'present', child: Text('Hadir (present)')),
                      DropdownMenuItem(value: 'late', child: Text('Terlambat (late)')),
                      DropdownMenuItem(value: 'sick', child: Text('Sakit (sick)')),
                      DropdownMenuItem(value: 'leave', child: Text('Izin / Cuti (leave)')),
                      DropdownMenuItem(value: 'absent', child: Text('Tidak Hadir (absent)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => status = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              NeoTextField(
                label: 'Catatan Koreksi',
                placeholder: 'Alasan koreksi data presensi',
                controller: notesController,
              ),
            ],
          );
        },
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
          text: 'Simpan Koreksi',
          variant: NeoButtonVariant.primary,
          size: NeoButtonSize.sm,
          onPressed: () async {
            Navigator.pop(context);
            final ok = await controller.correctAttendance(
              id: att.id,
              attendanceDate: dateController.text.trim(),
              clockIn: inController.text.trim(),
              clockOut: outController.text.trim(),
              status: status,
              notes: notesController.text.trim(),
              currentUser: auth.currentUser,
            );
            if (!mounted) return;
            if (ok) {
              Utils.toast(context, 'Data presensi berhasil dikoreksi!', ToastificationType.success, Icons.check, Utils.neoGreen);
            } else {
              Utils.toast(context, 'Gagal mengoreksi presensi', ToastificationType.error, Icons.close, Utils.neoRed);
            }
          },
        ),
      ],
    );
  }

  void _showAbsenceRequestDialog(
    AuthController auth,
    AttendanceController controller,
  ) {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final dateController = TextEditingController(text: todayStr);
    final notesController = TextEditingController();
    String status = 'sick';
    int employeeId = auth.currentUser?.employeeId ?? 3;

    NeoDialog.show(
      context: context,
      title: 'Pengajuan Izin / Sakit',
      maxWidth: 480,
      content: StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeoTextField(
                label: 'Tanggal',
                placeholder: todayStr,
                controller: dateController,
              ),
              const SizedBox(height: 12),
              Text(
                'JENIS PENGAJUAN',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Utils.neoBlack,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: const BoxDecoration(
                  color: Utils.neoCream,
                  borderRadius: BorderRadius.zero,
                  border: Utils.borderW,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: status,
                    isExpanded: true,
                    dropdownColor: Utils.neoCream,
                    items: const [
                      DropdownMenuItem(value: 'sick', child: Text('Sakit (Surat Dokter)')),
                      DropdownMenuItem(value: 'leave', child: Text('Izin / Cuti Terencana')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => status = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              NeoTextField(
                label: 'Keterangan / Alasan*',
                placeholder: 'Misal: Istirahat dokter karena demam',
                controller: notesController,
                maxLines: 3,
              ),
            ],
          );
        },
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
          text: 'Kirim Pengajuan',
          variant: NeoButtonVariant.primary,
          size: NeoButtonSize.sm,
          onPressed: () async {
            if (notesController.text.trim().isEmpty) {
              Utils.toast(context, 'Alasan keterangan wajib diisi', ToastificationType.warning, Icons.warning, Utils.neoYellow);
              return;
            }
            Navigator.pop(context);

            final ok = await controller.submitAbsenceRequest(
              employeeId: employeeId,
              attendanceDate: dateController.text.trim(),
              status: status,
              notes: notesController.text.trim(),
              currentUser: auth.currentUser,
            );
            if (!mounted) return;
            if (ok) {
              Utils.toast(context, 'Pengajuan ${status == 'sick' ? 'Sakit' : 'Izin'} berhasil dicatat!', ToastificationType.success, Icons.check, Utils.neoGreen);
            } else {
              Utils.toast(context, 'Gagal mencatat pengajuan', ToastificationType.error, Icons.close, Utils.neoRed);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final user = auth.currentUser;
    final isEmployee = auth.isEmployee;

    return Consumer<AttendanceController>(
      builder: (context, controller, child) {
        final filtered = controller.filteredAttendances;

        return MainLayout(
          title: isEmployee ? 'Presensi Saya' : 'Presensi & Kehadiran',
          activeMenu: 'kehadiran',
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Clock In / Out Card
                if (isEmployee || (user?.employeeId != null && user!.employeeId! > 0)) ...[
                  _buildClockInOutCard(controller, auth),
                  const SizedBox(height: 32),
                ],

                // 2. Toolbar & Filters
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
                                onChanged: (val) => controller.setSearchQuery(val),
                                decoration: InputDecoration(
                                  hintText: isEmployee
                                      ? 'Cari tanggal atau catatan presensi...'
                                      : 'Cari nama atau kode karyawan...',
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
                    // Status Filter
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
                          icon: const Icon(Icons.arrow_drop_down, color: Utils.neoBlack),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Utils.neoBlack,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('Semua Status')),
                            DropdownMenuItem(value: 'present', child: Text('Hadir')),
                            DropdownMenuItem(value: 'late', child: Text('Terlambat')),
                            DropdownMenuItem(value: 'sick', child: Text('Sakit')),
                            DropdownMenuItem(value: 'leave', child: Text('Cuti')),
                            DropdownMenuItem(value: 'absent', child: Text('Alpa')),
                          ],
                          onChanged: (val) {
                            if (val != null) controller.setSelectedStatus(val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    NeoButton(
                      text: '+ Ajukan Izin / Sakit',
                      variant: NeoButtonVariant.primary,
                      onPressed: () => _showAbsenceRequestDialog(auth, controller),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Attendances Single-Frame Table
                NeoTable(
                  isLoading: controller.isLoading,
                  emptyIcon: Icons.calendar_today,
                  emptyText: 'Tidak ada riwayat kehadiran ditemukan',
                  columnWidths: isEmployee
                      ? const {
                          0: FlexColumnWidth(1.4),
                          1: FlexColumnWidth(1.1),
                          2: FlexColumnWidth(1.1),
                          3: FlexColumnWidth(1.2),
                          4: FlexColumnWidth(1.5),
                          5: FlexColumnWidth(2.0),
                        }
                      : const {
                          0: FlexColumnWidth(2.0),
                          1: FlexColumnWidth(1.2),
                          2: FlexColumnWidth(1.0),
                          3: FlexColumnWidth(1.0),
                          4: FlexColumnWidth(1.0),
                          5: FlexColumnWidth(1.5),
                          6: FlexColumnWidth(1.8),
                          7: FlexColumnWidth(0.9),
                        },
                  headers: isEmployee
                      ? const [
                          NeoTableHeaderCell('TANGGAL'),
                          NeoTableHeaderCell('MASUK'),
                          NeoTableHeaderCell('PULANG'),
                          NeoTableHeaderCell('JAM KERJA'),
                          NeoTableHeaderCell('STATUS'),
                          NeoTableHeaderCell('CATATAN'),
                        ]
                      : const [
                          NeoTableHeaderCell('KARYAWAN'),
                          NeoTableHeaderCell('TANGGAL'),
                          NeoTableHeaderCell('MASUK'),
                          NeoTableHeaderCell('PULANG'),
                          NeoTableHeaderCell('JAM KERJA'),
                          NeoTableHeaderCell('STATUS'),
                          NeoTableHeaderCell('CATATAN'),
                          NeoTableHeaderCell('AKSI', alignment: Alignment.center),
                        ],
                  rows: filtered.map((att) {
                    if (isEmployee) {
                      return [
                        NeoTableCell(text: att.attendanceDate),
                        NeoTableCell(text: att.clockIn),
                        NeoTableCell(text: att.clockOut),
                        NeoTableCell(text: att.workingHoursFormatted),
                        NeoTableCell(child: NeoBadge.attendance(att.status)),
                        NeoTableCell(text: att.notes == '-' ? '' : att.notes),
                      ];
                    } else {
                      return [
                        NeoTableCell(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              NeoAvatar(name: att.employeeName, size: 28),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  att.employeeName,
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
                        NeoTableCell(text: att.attendanceDate),
                        NeoTableCell(text: att.clockIn),
                        NeoTableCell(text: att.clockOut),
                        NeoTableCell(text: att.workingHoursFormatted),
                        NeoTableCell(child: NeoBadge.attendance(att.status)),
                        NeoTableCell(text: att.notes == '-' ? '' : att.notes),
                        NeoTableCell(
                          alignment: Alignment.center,
                          child: auth.isAdmin
                              ? NeoIconButton(
                                  icon: Icons.edit,
                                  size: 32,
                                  tooltip: 'Koreksi Kehadiran',
                                  onPressed: () => _showCorrectionDialog(att, auth, controller),
                                )
                              : const Text('-'),
                        ),
                      ];
                    }
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
