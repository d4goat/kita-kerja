import 'package:flutter/material.dart';
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

  Widget _buildStatusBadge(String status) {
    String label = 'BELUM MULAI';
    Color bg = Colors.white;
    Color textCol = Utils.border;

    switch (status.toLowerCase()) {
      case 'in_progress':
        label = 'SEDANG DIKERJAKAN';
        bg = Utils.primary;
        textCol = Colors.white;
        break;
      case 'review':
        label = 'DITINJAU';
        bg = Utils.secondary;
        textCol = Utils.border;
        break;
      case 'completed':
        label = 'SELESAI';
        bg = Utils.success;
        textCol = Colors.white;
        break;
      case 'not_started':
      default:
        label = 'BELUM MULAI';
        bg = Colors.white;
        textCol = Utils.border;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Utils.border, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textCol,
        ),
      ),
    );
  }

  Widget _buildKaryawanPersonalDashboard(DashboardSummaryModel data, AuthController auth) {
    final user = auth.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Utils.border, width: 2),
            boxShadow: const [
              BoxShadow(color: Utils.border, offset: Offset(4, 4), blurRadius: 0),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Utils.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Utils.border, width: 2),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang, ${user?.name ?? 'Karyawan'}!',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Utils.border),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NIK: ${user?.employeeCode ?? 'EMP003'} • Departemen: ${user?.departmentName ?? 'Operasional'} • Role: Karyawan Pelaksana',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF666666), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: NeoButton(
                  text: 'Buka Presensi Hari Ini →',
                  backgroundColor: Utils.secondary,
                  textColor: Utils.border,
                  onPressed: () => Navigator.pushReplacementNamed(context, '/kehadiran'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Personal KPI Cards
        Row(
          children: [
            // Presensi Hari Ini
            _buildPersonalKPICard(
              title: 'PRESENSI HARI INI',
              value: data.hasClockedInToday ? (data.todayClockInTime ?? 'Hadir') : 'Belum Masuk',
              subtitle: data.hasClockedInToday
                  ? (data.todayClockOutTime != null && data.todayClockOutTime != '-' ? 'Sudah Pulang' : 'Sedang Masuk Kerja')
                  : 'Klik menu Kehadiran untuk Clock-In',
              icon: Icons.access_time_filled,
              color: data.hasClockedInToday ? Utils.success : Utils.danger,
            ),
            const SizedBox(width: 16),
            // Tugas Aktif
            _buildPersonalKPICard(
              title: 'TUGAS AKTIF SAYA',
              value: '${data.myActiveTasksCount} Tugas',
              subtitle: '${data.myInProgressTasksCount} Sedang Berjalan • ${data.myReviewTasksCount} Ditinjau',
              icon: Icons.assignment_turned_in,
              color: Utils.primary,
            ),
            const SizedBox(width: 16),
            // Beban Kerja
            _buildPersonalKPICard(
              title: 'BEBAN KERJA PRIBADI',
              value: '${data.myWorkloadPercentage.toStringAsFixed(1)}%',
              subtitle: '${data.myAssignedHours.toStringAsFixed(0)} Jam / ${data.myCapacityHours.toStringAsFixed(0)} Jam Kapasitas',
              icon: Icons.speed,
              color: data.myWorkloadPercentage > 100 ? Utils.danger : Utils.secondary,
            ),
            const SizedBox(width: 16),
            // Tugas Selesai
            _buildPersonalKPICard(
              title: 'TUGAS SELESAI',
              value: '${data.myCompletedTasksCount} Tugas',
              subtitle: 'Periode bulan berjalan',
              icon: Icons.check_circle,
              color: Utils.success,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Upcoming Tasks for this employee
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Utils.border, width: 2),
            boxShadow: const [
              BoxShadow(color: Utils.border, offset: Offset(4, 4), blurRadius: 0),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tugas Mendekati Deadline Saya',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Utils.border),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/pekerjaan'),
                      child: const Text('Lihat Semua Tugas →', style: TextStyle(fontWeight: FontWeight.w800, color: Utils.primary)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1.5, color: Color(0xFFE0E0E0)),
              if (data.taskList.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('Tidak ada tugas aktif yang mendekati deadline.', style: TextStyle(color: Color(0xFF666666))),
                  ),
                ),
              ] else ...[
                ...data.taskList.map((task) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFEBEBEB), width: 1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task['title'].toString(),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Utils.border),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Kategori: ${task['category_name'] ?? 'Umum'} • Deadline: ${_formatDate(task['deadline'].toString())}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(task['status'].toString()),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalKPICard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Utils.border, width: 2),
          boxShadow: const [
            BoxShadow(color: Utils.border, offset: Offset(3, 3), blurRadius: 0),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF666666)),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Utils.border, width: 1.5),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Utils.border),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminDashboard(DashboardSummaryModel data) {
    final overloaded = data.overloadedEmployee;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Alert Overload Banner
        if (overloaded != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Utils.mainBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Utils.border, width: 2),
              boxShadow: const [
                BoxShadow(color: Utils.border, offset: Offset(4, 4), blurRadius: 0),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Utils.danger, shape: BoxShape.circle),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Utils.border),
                      children: [
                        const TextSpan(text: 'Beban kerja melebihi kapasitas: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        TextSpan(
                          text: '${overloaded.employeeName} (${overloaded.percentageText})',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: Utils.danger),
                        ),
                      ],
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/pekerjaan'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Utils.border, width: 1.5),
                    backgroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 14, color: Utils.border),
                  label: const Text('Atur Ulang Tugas', style: TextStyle(fontWeight: FontWeight.w800, color: Utils.border, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // KPI Summary Cards
        Row(
          children: [
            _buildPersonalKPICard(
              title: 'TOTAL KARYAWAN',
              value: '${data.totalEmployees}',
              subtitle: 'Karyawan aktif terdaftar',
              icon: Icons.people,
              color: Utils.primary,
            ),
            const SizedBox(width: 16),
            _buildPersonalKPICard(
              title: 'HADIR HARI INI',
              value: '${data.presentToday}',
              subtitle: '${data.presentPercentage} tingkat kehadiran',
              icon: Icons.access_time_rounded,
              color: Utils.secondary,
            ),
            const SizedBox(width: 16),
            _buildPersonalKPICard(
              title: 'PEKERJAAN AKTIF',
              value: '${data.activeTasks}',
              subtitle: 'Dalam ${data.activeTeamsCount} departemen tim',
              icon: Icons.assignment_outlined,
              color: const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 16),
            _buildPersonalKPICard(
              title: 'LEMBUR HARI INI',
              value: '${data.overtimeCount}',
              subtitle: 'Staf lembur melebihi jam kerja',
              icon: Icons.timer,
              color: Utils.danger,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Company Workload Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workload Table
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Utils.border, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Utils.border, offset: Offset(4, 4), blurRadius: 0),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Beban Kerja Karyawan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Utils.border),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F1E8),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Utils.border, width: 1.5),
                          ),
                          child: const Text('Periode Berjalan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...data.workloadList.map((wl) => _buildWorkloadRow(wl)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Upcoming Tasks Table
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Utils.border, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Utils.border, offset: Offset(4, 4), blurRadius: 0),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pekerjaan Mendekati Deadline',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Utils.border),
                    ),
                    const SizedBox(height: 16),
                    ...data.taskList.map((task) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['title'].toString(),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Utils.border),
                                  ),
                                  Text(
                                    '${task['assigned_to_name']} • ${_formatDate(task['deadline'].toString())}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusBadge(task['status'].toString()),
                          ],
                        ),
                      );
                    }),
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
    final pct = (wl.percentage / 100.0).clamp(0.0, 1.0);
    final color = wl.isOverload ? Utils.danger : (wl.percentage >= 80 ? Utils.secondary : Utils.primary);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${wl.employeeName} (${wl.departmentName})',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Utils.border),
              ),
              Text(
                '${wl.assignedHours.toStringAsFixed(0)} / ${wl.capacityHours.toStringAsFixed(0)} Jam (${wl.percentageText})',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
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
                    child: CircularProgressIndicator(color: Utils.primary),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => controller.loadDashboard(auth.currentUser),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
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
