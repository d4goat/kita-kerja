import 'package:flutter/material.dart';
import 'package:kita_kerja/database/index.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/lib/utils.dart';
import 'package:kita_kerja/widgets/neo_components.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MySQLHelper _dbHelper = MySQLHelper();
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    final data = await _dbHelper.getDashboardData();

    if (mounted) {
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty || dateStr == '-') return '-';
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = int.tryParse(parts[1]) ?? 1;
        final day = parts[2];
        const monthNames = [
          '',
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agt',
          'Sep',
          'Okt',
          'Nov',
          'Des',
        ];
        final monthName = month >= 1 && month <= 12
            ? monthNames[month]
            : parts[1];
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

  @override
  Widget build(BuildContext context) {
    final data = _dashboardData;
    final overloaded = data?['overloaded_employee'] as Map<String, dynamic>?;
    final totalEmployees = data?['total_employees'] ?? 0;
    final presentToday = data?['present_today'] ?? 0;
    final presentPct = data?['present_percentage'] ?? '0%';
    final activeTasks = data?['active_tasks'] ?? 0;
    final activeTeams = data?['active_teams_count'] ?? 0;
    final overtimeCount = data?['overtime_count'] ?? 0;

    final workloadList = (data?['workload_list'] as List<dynamic>?) ?? [];
    final attendanceList = (data?['attendance_list'] as List<dynamic>?) ?? [];
    final taskList = (data?['task_list'] as List<dynamic>?) ?? [];

    return MainLayout(
      title: 'Dashboard',
      activeMenu: 'dashboard',
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: Utils.primary),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. ALERT BANNER OVERLOAD (Hanya jika ada yang overload)
                    if (overloaded != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Utils.mainBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Utils.border, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Utils.border,
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Utils.danger,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Utils.border,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'Beban kerja melebihi kapasitas: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          '${overloaded['name']} ${overloaded['percentage_text'] ?? ''}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Utils.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/pekerjaan',
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Utils.border,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                backgroundColor: Colors.white,
                              ),
                              icon: const Text(
                                'LIHAT BEBAN KERJA',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Utils.border,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              label: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: Utils.border,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 2. KPI CARDS (4 Columns Row)
                    Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            'TOTAL KARYAWAN',
                            '$totalEmployees',
                            badgeText: 'AKTIF',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildKpiCard(
                            'HADIR HARI INI',
                            '$presentToday / $totalEmployees',
                            badgeText: presentPct,
                            badgeColor: const Color(0xFFE2F9E5),
                            badgeTextColor: const Color(0xFF1B7F2D),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildKpiCard(
                            'PEKERJAAN AKTIF',
                            '$activeTasks',
                            badgeText: '$activeTeams TIM',
                            badgeColor: const Color(0xFFFFF7DB),
                            badgeTextColor: const Color(0xFF8C6600),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildKpiCard(
                            'LEMBUR',
                            '$overtimeCount orang',
                            showYellowDot: overtimeCount > 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 3. MIDDLE SECTION (Workload Chart + Attendance Table)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Beban Kerja Per Karyawan
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.bar_chart_rounded,
                                          size: 20,
                                          color: Utils.border,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'BEBAN KERJA PER KARYAWAN',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: Utils.border,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0F0F0),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'BATAS AMAN: 100%',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                if (workloadList.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(
                                      child: Text(
                                        'Belum ada data beban kerja',
                                        style: TextStyle(
                                          color: Color(0xFF777777),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ...workloadList.map((item) {
                                    final double factor =
                                        (item['factor'] as num?)?.toDouble() ??
                                        0.0;
                                    final String pctText =
                                        item['percentage_text']?.toString() ??
                                        '0%';
                                    final bool isOver =
                                        item['is_overload'] == true;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 14,
                                      ),
                                      child: _buildWorkloadItem(
                                        item['name'].toString(),
                                        factor,
                                        pctText,
                                        isOverload: isOver,
                                      ),
                                    );
                                  }),
                                const SizedBox(height: 6),
                                const Divider(
                                  color: Color(0xFFE5E5E5),
                                  height: 1,
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Utils.danger,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Overload > 100%',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF666666),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                    Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Utils.primary,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Optimal Terkendali',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF666666),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Right Column: Kehadiran Hari Ini
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'KEHADIRAN HARI INI',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Utils.border,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacementNamed(
                                            context,
                                            '/kehadiran',
                                          );
                                        },
                                        child: const Text(
                                          'Lihat Semua >',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Utils.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                NeoTable(
                                  showContainer: false,
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(1),
                                    2: FlexColumnWidth(1.2),
                                  },
                                  headers: const [
                                    NeoTableHeaderCell('NAMA'),
                                    NeoTableHeaderCell('MASUK'),
                                    NeoTableHeaderCell('PULANG'),
                                  ],
                                  rows: attendanceList.isEmpty
                                      ? []
                                      : attendanceList.map((att) {
                                          final bool isOt =
                                              att['is_overtime'] == true;
                                          return [
                                            NeoTableCell(
                                              text:
                                                  att['employee_name']
                                                      ?.toString() ??
                                                  '-',
                                              isBold: true,
                                            ),
                                            NeoTableCell(
                                              text:
                                                  att['clock_in']?.toString() ??
                                                  '-',
                                            ),
                                            NeoTableCell(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    att['clock_out']
                                                            ?.toString() ??
                                                        '-',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Utils.border,
                                                    ),
                                                  ),
                                                  if (isOt) ...[
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Utils.secondary,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        border: Border.all(
                                                          color: Utils.border,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'LEMBUR',
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: Utils.border,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ];
                                        }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 4. BOTTOM SECTION (Pekerjaan Mendekati Deadline)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
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
                              Row(
                                children: const [
                                  Icon(
                                    Icons.pie_chart_outline_rounded,
                                    size: 20,
                                    color: Utils.border,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'PEKERJAAN MENDEKATI DEADLINE',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Utils.border,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0F0),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Utils.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  '${taskList.length} PRIORITAS',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Utils.danger,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          NeoTable(
                            showContainer: false,
                            columnWidths: const {
                              0: FlexColumnWidth(2.5),
                              1: FlexColumnWidth(1.5),
                              2: FlexColumnWidth(1.5),
                              3: FlexColumnWidth(1.5),
                            },
                            headers: const [
                              NeoTableHeaderCell('TUGAS'),
                              NeoTableHeaderCell('PENANGGUNG JAWAB'),
                              NeoTableHeaderCell('DEADLINE'),
                              NeoTableHeaderCell('STATUS'),
                            ],
                            rows: taskList.isEmpty
                                ? []
                                : taskList.map((task) {
                                    final String priority =
                                        task['priority']
                                            ?.toString()
                                            .toLowerCase() ??
                                        '';
                                    Color dotColor = Colors.grey;
                                    if (priority == 'urgent') {
                                      dotColor = Utils.danger;
                                    } else if (priority == 'high') {
                                      dotColor = Colors.blue;
                                    } else if (priority == 'medium') {
                                      dotColor = Utils.secondary;
                                    }

                                    return [
                                      NeoTableCell(
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: dotColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                task['title']?.toString() ??
                                                    '-',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Utils.border,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      NeoTableCell(
                                        text:
                                            task['assigned_to_name']
                                                ?.toString() ??
                                            '-',
                                      ),
                                      NeoTableCell(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.calendar_today_outlined,
                                              size: 14,
                                              color: Utils.danger,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _formatDate(
                                                task['deadline']?.toString() ??
                                                    '',
                                              ),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Utils.border,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      NeoTableCell(
                                        child: _buildStatusBadge(
                                          task['status']?.toString() ?? '',
                                        ),
                                      ),
                                    ];
                                  }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKpiCard(
    String title,
    String value, {
    String? badgeText,
    Color badgeColor = const Color(0xFFF0F0F0),
    Color badgeTextColor = Utils.border,
    bool showYellowDot = false,
  }) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF777777),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Utils.border,
                ),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Utils.border, width: 1.5),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              if (showYellowDot)
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Utils.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Utils.border, width: 1.5),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkloadItem(
    String name,
    double factor,
    String percentageText, {
    bool isOverload = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Utils.border,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            double barWidth =
                constraints.maxWidth * (factor > 1.0 ? 1.0 : factor);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Background Track
                Container(
                  height: 22,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Utils.border, width: 1.5),
                  ),
                ),
                // Progress Bar
                Container(
                  height: 22,
                  width: barWidth,
                  decoration: BoxDecoration(
                    color: isOverload ? Utils.danger : Utils.primary,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Utils.border, width: 1.5),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isOverload) ...[
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        percentageText,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
