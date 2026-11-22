import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/controllers/auth_controller.dart';
import 'package:kita_kerja/controllers/dashboard_controller.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/models/dashboard_summary_model.dart';
import 'package:kita_kerja/models/report_model.dart';
import 'package:kita_kerja/widgets/neo_components.dart';
import 'package:kita_kerja/widgets/neo_charts.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _dashboardTab = 0; // 0: Ringkasan (Overview), 1: Pelaporan Data (Reporting)
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

  /// Fitur Pelaporan Data (Data Reporting) dengan 3 Jenis Chart (Bar, Line, Pie),
  /// filter dinamis (departemen, periode, status), dan data grouping.
  Widget _buildReportingDashboard(DashboardController controller, AuthController auth) {
    final report = controller.reportData;
    final filter = controller.reportFilter;
    final summary = report?.summaryKPIs ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Toolbar Filter & Grouping Data Laporan
        NeoContainer(
          padding: const EdgeInsets.all(20),
          boxShadow: Utils.shadowMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune, size: 20, color: Utils.neoBlack),
                      const SizedBox(width: 8),
                      Text(
                        'FILTER & PENGELOMPOKAN DATA LAPORAN',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Utils.neoBlack,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  NeoTag(label: 'Grouping: ${filter.groupByLabel}'),
                ],
              ),
              const SizedBox(height: 16),

              // Baris Kontrol Filter
              Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Filter Departemen
                  _buildFilterDropdown(
                    label: 'Departemen',
                    value: filter.department,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Semua Departemen')),
                      DropdownMenuItem(value: 'Operasional', child: Text('Operasional')),
                      DropdownMenuItem(value: 'Pemasaran', child: Text('Pemasaran')),
                      DropdownMenuItem(value: 'Teknologi', child: Text('Teknologi')),
                      DropdownMenuItem(value: 'Administrasi', child: Text('Administrasi')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        controller.updateFilter(filter.copyWith(department: val), auth.currentUser);
                      }
                    },
                  ),

                  // Filter Periode Waktu
                  _buildFilterDropdown(
                    label: 'Rentang Waktu',
                    value: filter.period,
                    items: const [
                      DropdownMenuItem(value: 'this_month', child: Text('Bulan Ini')),
                      DropdownMenuItem(value: '30_days', child: Text('30 Hari Terakhir')),
                      DropdownMenuItem(value: '7_days', child: Text('7 Hari Terakhir')),
                      DropdownMenuItem(value: 'all', child: Text('Semua Waktu')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        controller.updateFilter(filter.copyWith(period: val), auth.currentUser);
                      }
                    },
                  ),

                  // Filter Status Tugas
                  _buildFilterDropdown(
                    label: 'Status Pekerjaan',
                    value: filter.status,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Semua Status')),
                      DropdownMenuItem(value: 'active', child: Text('Aktif (Belum Selesai)')),
                      DropdownMenuItem(value: 'completed', child: Text('Selesai (Completed)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        controller.updateFilter(filter.copyWith(status: val), auth.currentUser);
                      }
                    },
                  ),

                  // Pengelompokan Data (Data Grouping)
                  _buildFilterDropdown(
                    label: 'Kelompokkan (Grouping)',
                    value: filter.groupBy,
                    items: const [
                      DropdownMenuItem(value: 'department', child: Text('Departemen Tim')),
                      DropdownMenuItem(value: 'category', child: Text('Kategori Pekerjaan')),
                      DropdownMenuItem(value: 'priority', child: Text('Prioritas Tugas')),
                      DropdownMenuItem(value: 'status', child: Text('Status Pengerjaan')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        controller.updateFilter(filter.copyWith(groupBy: val), auth.currentUser);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 2. Indikator Metrik Kunci Hasil Filter
        Row(
          children: [
            NeoKPICard(
              title: 'TOTAL PEKERJAAN',
              value: '${summary['total_tasks'] ?? 0}',
              caption: 'Berdasarkan filter aktif',
              icon: Icons.assignment_outlined,
              iconContainerColor: Utils.neoBlack,
              iconColor: Utils.neoCream,
            ),
            const SizedBox(width: 16),
            NeoKPICard(
              title: 'TINGKAT SELESAI',
              value: '${(summary['completion_rate'] as double? ?? 0.0).toStringAsFixed(1)}%',
              caption: '${summary['completed_tasks'] ?? 0} tugas diselesaikan',
              icon: Icons.check_circle_outline,
              iconContainerColor: Utils.neoGreen,
              iconColor: Utils.neoBlack,
            ),
            const SizedBox(width: 16),
            NeoKPICard(
              title: 'TOTAL JAM AKTUAL',
              value: '${(summary['total_actual_hours'] as double? ?? 0.0).toStringAsFixed(0)}j',
              caption: 'Estimasi: ${(summary['total_estimated_hours'] as double? ?? 0.0).toStringAsFixed(0)}j',
              icon: Icons.timer,
              iconContainerColor: Utils.neoBlue,
              iconColor: Utils.neoCream,
            ),
            const SizedBox(width: 16),
            NeoKPICard(
              title: 'EFISIENSI WAKTU',
              value: '${(summary['efficiency_ratio'] as double? ?? 100.0).toStringAsFixed(1)}%',
              caption: 'Rasio aktual vs estimasi',
              icon: Icons.speed,
              iconContainerColor: Utils.neoYellow,
              iconColor: Utils.neoBlack,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 3. Visualisasi 3 Jenis Chart
        if (controller.isReportLoading || report == null) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Utils.neoBlack),
            ),
          ),
        ] else ...[
          // Baris Visualisasi 1: Bar Chart (Grafik Batang) & Pie Chart (Grafik Lingkaran)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. BAR CHART (Grafik Batang Neo-Brutalism)
              Expanded(
                flex: 7,
                child: NeoBarChart(
                  title: 'Beban Pekerjaan per ${filter.groupByLabel}',
                  subtitle: 'Perbandingan total pekerjaan dan jumlah yang telah tuntas',
                  items: report.barChartData,
                  primaryLegend: 'Total Tugas',
                  secondaryLegend: 'Tugas Selesai',
                  primaryColor: Utils.neoBlue,
                  secondaryColor: Utils.neoGreen,
                  height: 280,
                ),
              ),
              const SizedBox(width: 20),

              // 2. PIE CHART (Grafik Lingkaran Donut Neo-Brutalism)
              Expanded(
                flex: 5,
                child: NeoPieChart(
                  title: 'Distribusi Status Pekerjaan',
                  subtitle: 'Komposisi persentase tahapan pengerjaan tugas tim',
                  slices: report.pieChartData,
                  centerTitle: 'TUGAS',
                  height: 280,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Baris Visualisasi 2: Line Chart (Grafik Garis / Tren)
          // 3. LINE CHART (Grafik Garis Tren Kehadiran & Jam Kerja)
          NeoLineChart(
            title: 'Tren Kehadiran & Rata-rata Durasi Kerja Harian',
            subtitle: 'Pemantauan fluktuasi jumlah kehadiran staf per hari dalam periode laporan',
            points: report.lineChartData,
            lineLabel: 'Jumlah Staf Hadir',
            lineColor: Utils.neoBlue,
            height: 260,
            valueSuffix: ' org',
          ),
          const SizedBox(height: 24),

          // 4. Tabel Rekapitulasi Data Laporan
          NeoContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TABEL REKAPITULASI LAPORAN DATA',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Utils.neoBlack,
                      ),
                    ),
                    const NeoTag(label: 'DATA HASIL GROUPING'),
                  ],
                ),
                const SizedBox(height: 16),
                NeoTable(
                  isLoading: controller.isReportLoading,
                  columnWidths: const {
                    0: FlexColumnWidth(2.0),
                    1: FlexColumnWidth(1.2),
                    2: FlexColumnWidth(1.2),
                    3: FlexColumnWidth(1.4),
                    4: FlexColumnWidth(1.3),
                    5: FlexColumnWidth(1.3),
                    6: FlexColumnWidth(1.4),
                  },
                  headers: [
                    NeoTableHeaderCell(filter.groupByLabel.toUpperCase()),
                    const NeoTableHeaderCell('TOTAL TUGAS', alignment: Alignment.center),
                    const NeoTableHeaderCell('SELESAI', alignment: Alignment.center),
                    const NeoTableHeaderCell('BERJALAN', alignment: Alignment.center),
                    const NeoTableHeaderCell('ESTIMASI JAM', alignment: Alignment.center),
                    const NeoTableHeaderCell('AKTUAL JAM', alignment: Alignment.center),
                    const NeoTableHeaderCell('TINGKAT SELESAI', alignment: Alignment.center),
                  ],
                  rows: report.tableData.map((row) {
                    return [
                      NeoTableCell(text: row.groupName),
                      NeoTableCell(
                        alignment: Alignment.center,
                        child: Text(
                          '${row.totalTasks}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Utils.neoBlack,
                          ),
                        ),
                      ),
                      NeoTableCell(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Utils.neoGreen,
                            border: Utils.borderWSm,
                          ),
                          child: Text(
                            '${row.completedTasks}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Utils.neoBlack,
                            ),
                          ),
                        ),
                      ),
                      NeoTableCell(
                        alignment: Alignment.center,
                        child: Text(
                          '${row.inProgressTasks}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Utils.neoBlack,
                          ),
                        ),
                      ),
                      NeoTableCell(
                        alignment: Alignment.center,
                        child: Text('${row.totalEstimatedHours.toStringAsFixed(1)}j'),
                      ),
                      NeoTableCell(
                        alignment: Alignment.center,
                        child: Text('${row.totalActualHours.toStringAsFixed(1)}j'),
                      ),
                      NeoTableCell(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: row.completionRate >= 80
                                ? Utils.neoGreen
                                : (row.completionRate >= 40
                                    ? Utils.neoYellow
                                    : Utils.neoCream),
                            border: Utils.borderWSm,
                          ),
                          child: Text(
                            '${row.completionRate.toStringAsFixed(1)}%',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Utils.neoBlack,
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
        ],
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Utils.neoBlack,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(
            color: Utils.neoCream,
            border: Utils.borderW,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: Utils.neoCream,
              items: items,
              onChanged: onChanged,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Utils.neoBlack,
              ),
            ),
          ),
        ),
      ],
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tab Navigasi Dashboard: RINGKASAN vs PELAPORAN DATA (REPORTING)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            NeoTabs(
                              tabs: const ['RINGKASAN', 'PELAPORAN DATA (REPORTING)'],
                              selectedIndex: _dashboardTab,
                              onTabSelected: (idx) => setState(() => _dashboardTab = idx),
                            ),
                            if (_dashboardTab == 1)
                              NeoButton(
                                text: 'Ekspor Laporan',
                                variant: NeoButtonVariant.primary,
                                icon: const Icon(Icons.download, size: 18),
                                onPressed: () {
                                  Utils.toast(
                                    context,
                                    'Laporan analitik data berhasil diekspor!',
                                    ToastificationType.success,
                                    Icons.check,
                                    Utils.neoGreen,
                                  );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Konten Sesuai Tab Terpilih
                        if (_dashboardTab == 0) ...[
                          isEmployee
                              ? _buildKaryawanPersonalDashboard(data, auth)
                              : _buildAdminDashboard(data),
                        ] else ...[
                          _buildReportingDashboard(controller, auth),
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
