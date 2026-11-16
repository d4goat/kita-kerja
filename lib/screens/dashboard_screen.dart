import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/controllers/auth_controller.dart';
import 'package:kita_kerja/controllers/dashboard_controller.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/models/dashboard_summary_model.dart';
import 'package:kita_kerja/widgets/neo_components.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthController>(context, listen: false);
      Provider.of<DashboardController>(context, listen: false).loadDashboard(auth.currentUser);
    });
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty || dateStr == '-') return '-';
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = int.tryParse(parts[1]) ?? 1;
        final day = parts[2];
        const monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
        final monthName = month >= 1 && month <= 12 ? monthNames[month] : parts[1];
        return '$day $monthName $year';
      }
    } catch (_) {}
    return dateStr;
  }

  Widget _buildKaryawanPersonalDashboard(DashboardSummaryModel data, AuthController auth) {
    final user = auth.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Banner (Neo-Brutalism container)
        NeoContainer(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              NeoAvatar(name: user?.name ?? 'Karyawan', size: 52),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang, ${user?.name ?? 'Karyawan'}!',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Utils.neoBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NIK: ${user?.employeeCode ?? 'EMP003'} • Departemen: ${user?.departmentName ?? 'Operasional'} • Role: Karyawan Pelaksana',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Utils.neoBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              NeoButton(
                text: 'BUKA PRESENSI',
                variant: NeoButtonVariant.secondary,
                onPressed: () => Navigator.pushReplacementNamed(context, '/kehadiran'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Personal KPI Cards (Section 7.1)
        Row(
          children: [
            NeoKPICard(
              title: 'PRESENSI HARI INI',
              value: data.hasClockedInToday ? (data.todayClockInTime ?? 'Hadir') : 'Belum Masuk',
              caption: data.hasClockedInToday
                  ? (data.todayClockOutTime != null && data.todayClockOutTime != '-' ? 'Sudah Pulang' : 'Sedang Masuk Kerja')
                  : 'Belum Clock-In hari ini',
              icon: Icons.access_time_filled,
              iconContainerColor: data.hasClockedInToday ? Utils.neoGreen : Utils.neoRed,
              iconColor: Utils.neoBlack,
            ),
            const SizedBox(width: 16),
            NeoKPICard(
              title: 'TUGAS AKTIF SAYA',
              value: '${data.myActiveTasksCount}',
              caption: '${data.myInProgressTasksCount} Berjalan • ${data.myReviewTasksCount} Ditinjau',
              icon: Icons.assignment,
              iconContainerColor: Utils.neoBlue,
              iconColor: Utils.neoCream,
            ),
            const SizedBox(width: 16),
            NeoKPICard(
              title: 'BEBAN KERJA PRIBADI',
              value: '${data.myWorkloadPercentage.toStringAsFixed(1)}%',
              caption: '${data.myAssignedHours.toStringAsFixed(0)}j / ${data.myCapacityHours.toStringAsFixed(0)}j Kapasitas',
              icon: Icons.speed,
              iconContainerColor: data.myWorkloadPercentage > 100 ? Utils.neoRed : Utils.neoYellow,
              iconColor: Utils.neoBlack,
            ),
            const SizedBox(width: 16),
            NeoKPICard(
              title: 'TUGAS SELESAI',
              value: '${data.myCompletedTasksCount}',
              caption: 'Periode bulan berjalan',
              icon: Icons.check,
              iconContainerColor: Utils.neoGreen,
              iconColor: Utils.neoBlack,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 8/4 Layout: Upcoming Tasks (8) + Personal Workload Meter (4)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left 8/12: Upcoming Tasks
            Expanded(
              flex: 8,
              child: NeoContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PEKERJAAN SAYA',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Utils.neoBlack,
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, '/pekerjaan'),
                            child: Text(
                              'Lihat Semua →',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Utils.neoBlack,
                                decoration: TextDecoration.underline,
                                decorationThickness: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (data.taskList.isEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text('Tidak ada tugas aktif yang mendekati deadline.'),
                        ),
                      ),
                    ] else ...[
                      ...data.taskList.map((task) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(bottom: Utils.borderSideWSm),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task['title'].toString(),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Utils.neoBlack,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Kategori: ${task['category_name'] ?? 'Umum'} • Deadline: ${_formatDate(task['deadline'].toString())}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Utils.neoBlack,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              NeoBadge.taskStatus(task['status'].toString()),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),

            // Right 4/12: Personal Workload Meter
            Expanded(
              flex: 4,
              child: NeoContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATUS BEBAN KERJA',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Utils.neoBlack,
                      ),
                    ),
                    const SizedBox(height: 16),
                    NeoWorkloadMeter(
                      percentage: data.myWorkloadPercentage,
                      label: user?.name ?? 'Saya',
                      detailText: 'Ditugaskan ${data.myAssignedHours.toStringAsFixed(0)}j / Kapasitas ${data.myCapacityHours.toStringAsFixed(0)}j',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminDashboard(DashboardSummaryModel data) {
    final overloaded = data.overloadedEmployee;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 7.2 Banner Peringatan Beban Kerja (Kondisional Bahaya)
        if (overloaded != null) ...[
          NeoAlert.danger(
            text: 'Beban kerja melebihi kapasitas: ${overloaded.employeeName} (${overloaded.percentageText})',
            action: NeoButton(
              text: 'Atur Pekerjaan',
              size: NeoButtonSize.sm,
              variant: NeoButtonVariant.neutral,
              onPressed: () => Navigator.pushReplacementNamed(context, '/pekerjaan'),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // 7.1 Baris 4 Kartu KPI
        Row(
          children: [
            NeoKPICard(
              title: 'TOTAL KARYAWAN',
              value: '${data.totalEmployees}',
              caption: 'Karyawan aktif terdaftar',
              icon: Icons.people,
              iconContainerColor: Utils.neoBlack,
              iconColor: Utils.neoCream,
            ),
            const SizedBox(width: 16),
            NeoKPICard(
              title: 'HADIR HARI INI',
              value: '${data.presentToday}',
              caption: '${data.presentPercentage} tingkat kehadiran',
              icon: Icons.calendar_today,
              iconContainerColor: Utils.neoGreen,
              iconColor: Utils.neoBlack,
            ),
            const SizedBox(width: 16),
            NeoKPICard(
              title: 'PEKERJAAN AKTIF',
              value: '${data.activeTasks}',
              caption: 'Dalam ${data.activeTeamsCount} tim departemen',
              icon: Icons.assignment,
              iconContainerColor: Utils.neoBlue,
              iconColor: Utils.neoCream,
            ),
            const SizedBox(width: 16),
            NeoKPICard(
              title: 'LEMBUR HARI INI',
              value: '${data.overtimeCount}',
              caption: 'Staf lembur hari ini',
              icon: Icons.access_time_filled,
              iconContainerColor: Utils.neoYellow,
              iconColor: Utils.neoBlack,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 8.2 Baris kedua: Asimetris 8/4 Grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kolom 8/12: Meter Beban Kerja Karyawan
            Expanded(
              flex: 8,
              child: NeoContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BEBAN KERJA KARYAWAN',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Utils.neoBlack,
                          ),
                        ),
                        const NeoTag(label: 'PERIODE BERJALAN'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (data.workloadList.isEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('Belum ada data beban kerja.')),
                      ),
                    ] else ...[
                      ...data.workloadList.map((wl) => _buildWorkloadRow(wl)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),

            // Kolom 4/12: Pekerjaan Mendekati Deadline
            Expanded(
              flex: 4,
              child: NeoContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DEADLINE TERDEKAT',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Utils.neoBlack,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (data.taskList.isEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('Tidak ada pekerjaan mendekati deadline.')),
                      ),
                    ] else ...[
                      ...data.taskList.map((task) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(bottom: Utils.borderSideWSm),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      task['title'].toString(),
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Utils.neoBlack,
                                      ),
                                    ),
                                  ),
                                  NeoBadge.taskStatus(task['status'].toString()),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${task['assigned_to_name']} • ${_formatDate(task['deadline'].toString())}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Utils.neoBlack,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkloadRow(WorkloadModel wl) {
    return NeoWorkloadMeter(
      percentage: wl.percentage,
      label: '${wl.employeeName} (${wl.departmentName})',
      detailText: '${wl.assignedHours.toStringAsFixed(0)}j / ${wl.capacityHours.toStringAsFixed(0)}j Kapasitas (${wl.percentageText})',
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final isEmployee = auth.isEmployee;

    return Consumer<DashboardController>(
      builder: (context, controller, child) {
        final data = controller.dashboardData;

        return MainLayout(
          title: isEmployee ? 'Dashboard Pribadi' : 'Dashboard Utama',
          activeMenu: 'dashboard',
          child: controller.isLoading || data == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: Utils.neoBlack),
                  ),
                )
              : RefreshIndicator(
                  color: Utils.neoBlack,
                  backgroundColor: Utils.neoCream,
                  onRefresh: () => controller.loadDashboard(auth.currentUser),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: isEmployee
                        ? _buildKaryawanPersonalDashboard(data, auth)
                        : _buildAdminDashboard(data),
                  ),
                ),
        );
      },
    );
  }
}
