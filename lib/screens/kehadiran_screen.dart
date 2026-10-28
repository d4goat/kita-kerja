import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kita_kerja/controllers/attendance_controller.dart';
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

  String _formatCurrentTime() {
    final h = _currentTime.hour.toString().padLeft(2, '0');
    final m = _currentTime.minute.toString().padLeft(2, '0');
    final s = _currentTime.second.toString().padLeft(2, '0');
    return '$h:$m:$s WIB';
  }

  String _formatTodayDate() {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    final dayName = days[_currentTime.weekday % 7];
    final monthName = months[_currentTime.month];
    return '$dayName, ${_currentTime.day} $monthName ${_currentTime.year}';
  }

  Widget _buildClockInOutCard(AttendanceController controller, AuthController auth) {
    final user = auth.currentUser;
    final today = controller.todayAttendance;
    final hasIn = controller.hasClockedInToday;
    final hasOut = controller.hasClockedOutToday;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Utils.border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Utils.border,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Utils.secondary,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Utils.border, width: 1.5),
                        ),
                        child: const Icon(Icons.access_time_filled, size: 18, color: Utils.border),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Presensi Mandiri: ${user?.name ?? 'Karyawan'} (${user?.employeeCode ?? 'EMP003'})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Utils.border,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatTodayDate()} • Jadwal: 08:00 - 17:00 WIB',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF666666), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              // Live Digital Clock
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F1E8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Utils.border, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 18, color: Utils.primary),
                    const SizedBox(width: 8),
                    Text(
                      _formatCurrentTime(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Utils.border,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE5E5E5), thickness: 1.5),
          const SizedBox(height: 16),

          // Status & Buttons Action
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status Today Card
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    // Clock In Info
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: hasIn ? const Color(0xFFE2F9E5) : const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hasIn ? const Color(0xFF1B7F2D) : const Color(0xFFCCCCCC),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'JAM MASUK',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF666666)),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  hasIn ? Icons.check_circle : Icons.radio_button_unchecked,
                                  size: 18,
                                  color: hasIn ? const Color(0xFF1B7F2D) : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  hasIn ? '${today?.clockIn} WIB' : 'Belum Masuk',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: hasIn ? const Color(0xFF1B7F2D) : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Clock Out Info
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: hasOut ? const Color(0xFFE2F9E5) : const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hasOut ? const Color(0xFF1B7F2D) : const Color(0xFFCCCCCC),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'JAM PULANG',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF666666)),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  hasOut ? Icons.check_circle : Icons.radio_button_unchecked,
                                  size: 18,
                                  color: hasOut ? const Color(0xFF1B7F2D) : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  hasOut ? '${today?.clockOut} WIB' : (hasIn ? 'Sedang Bekerja' : '-'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: hasOut ? const Color(0xFF1B7F2D) : (hasIn ? Utils.primary : Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Action Buttons
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    if (!hasIn) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: NeoButton(
                          text: 'MASUK KERJA (CLOCK IN)',
                          backgroundColor: Utils.primary,
                          isLoading: controller.isLoading,
                          onPressed: () async {
                            if (user == null) return;
                            final ok = await controller.clockIn(user);
                            if (ok && mounted) {
                              Utils.toast(
                                context,
                                'Berhasil Masuk Kerja! Semangat beraktivitas.',
                                ToastificationType.success,
                                Icons.check_circle,
                                Utils.success,
                              );
                            }
                          },
                        ),
                      ),
                    ] else if (!hasOut) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: NeoButton(
                          text: 'PULANG KERJA (CLOCK OUT)',
                          backgroundColor: Utils.danger,
                          isLoading: controller.isLoading,
                          onPressed: () async {
                            if (user == null) return;
                            final ok = await controller.clockOut(user);
                            if (ok && mounted) {
                              Utils.toast(
                                context,
                                'Berhasil Pulang Kerja! Jam kerja Anda telah tercatat.',
                                ToastificationType.success,
                                Icons.check_circle,
                                Utils.success,
                              );
                            }
                          },
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2F9E5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF1B7F2D), width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.verified, color: Color(0xFF1B7F2D), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Presensi Hari Ini Lengkap',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1B7F2D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Clock In / Out Card (Khusus role Karyawan atau jika user memiliki employeeId)
                if (isEmployee || (user?.employeeId != null && user!.employeeId! > 0)) ...[
                  _buildClockInOutCard(controller, auth),
                  const SizedBox(height: 24),
                ],

                // 2. Filter Bar
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
                                onChanged: (val) => controller.setSearchQuery(val),
                                decoration: InputDecoration(
                                  hintText: isEmployee
                                      ? 'Cari tanggal atau catatan presensi...'
                                      : 'Cari nama atau NIK karyawan...',
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
                          value: controller.selectedStatus,
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
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Attendances Table
                NeoTable(
                  isLoading: controller.isLoading,
                  emptyIcon: Icons.event_busy,
                  emptyText: 'Tidak ada riwayat kehadiran ditemukan',
                  columnWidths: isEmployee
                      ? const {
                          0: FlexColumnWidth(1.4),
                          1: FlexColumnWidth(1.1),
                          2: FlexColumnWidth(1.1),
                          3: FlexColumnWidth(1.2),
                          4: FlexColumnWidth(1.2),
                          5: FlexColumnWidth(2.0),
                        }
                      : const {
                          0: FlexColumnWidth(2.0),
                          1: FlexColumnWidth(1.2),
                          2: FlexColumnWidth(1.0),
                          3: FlexColumnWidth(1.0),
                          4: FlexColumnWidth(1.2),
                          5: FlexColumnWidth(1.2),
                          6: FlexColumnWidth(1.8),
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
                        ],
                  rows: filtered.map((att) {
                    final st = att.status;
                    final rowCells = <NeoTableCell>[];

                    if (!isEmployee) {
                      rowCells.add(
                        NeoTableCell(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                att.employeeName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Utils.border,
                                ),
                              ),
                              Text(
                                '${att.employeeCode} • ${att.departmentName}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    rowCells.addAll([
                      NeoTableCell(text: att.attendanceDate),
                      NeoTableCell(text: att.clockIn),
                      NeoTableCell(text: att.clockOut),
                      NeoTableCell(text: '${att.workingHoursFormatted} Jam'),
                      NeoTableCell(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusBg(st),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Utils.border, width: 1.5),
                            ),
                            child: Text(
                              att.statusLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _getStatusText(st),
                              ),
                            ),
                          ),
                        ),
                      ),
                      NeoTableCell(text: att.notes),
                    ]);

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
