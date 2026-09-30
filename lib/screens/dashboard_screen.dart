import 'package:flutter/material.dart';
import 'package:kita_kerja/layouts/main_layout.dart';
import 'package:kita_kerja/lib/utils.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Dashboard',
      activeMenu: 'dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ALERT BANNER OVERLOAD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4F4),
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
                      text: const TextSpan(
                        style: TextStyle(fontSize: 14, color: Utils.border),
                        children: [
                          TextSpan(
                            text: 'Beban kerja melebihi kapasitas: ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: 'Budi Santoso 112,5%',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Utils.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Utils.border, width: 2),
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

            // 2. KPI CARDS (4 Columns Row)
            Row(
              children: [
                Expanded(child: _buildKpiCard('TOTAL KARYAWAN', '6', badgeText: 'AKTIF')),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    'HADIR HARI INI',
                    '4 / 6',
                    badgeText: '66.7%',
                    badgeColor: const Color(0xFFE2F9E5),
                    badgeTextColor: const Color(0xFF1B7F2D),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    'PEKERJAAN AKTIF',
                    '7',
                    badgeText: '3 TIM',
                    badgeColor: const Color(0xFFFFF7DB),
                    badgeTextColor: const Color(0xFF8C6600),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    'LEMBUR',
                    '1 orang',
                    showYellowDot: true,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.bar_chart_rounded, size: 20, color: Utils.border),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        _buildWorkloadItem('Budi Santoso', 1.125, '112,5%', isOverload: true),
                        const SizedBox(height: 14),
                        _buildWorkloadItem('Dimas Pratama', 1.0, '100%'),
                        const SizedBox(height: 14),
                        _buildWorkloadItem('Rina Marlina', 0.75, '75%'),
                        const SizedBox(height: 14),
                        _buildWorkloadItem('Lestari Ayu', 0.625, '62,5%'),
                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFFE5E5E5), height: 1),
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
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Overload > 100%',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF666666)),
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
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Optimal Terkendali',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF666666)),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                onTap: () {},
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
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1.2),
                          },
                          border: const TableBorder(
                            horizontalInside: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                          ),
                          children: [
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Color(0xFFF9F9F9),
                              ),
                              children: [
                                _buildTableCell('NAMA', isHeader: true),
                                _buildTableCell('MASUK', isHeader: true),
                                _buildTableCell('PULANG', isHeader: true),
                              ],
                            ),
                            TableRow(
                              children: [
                                _buildTableCell('Budi Santoso', isBold: true),
                                _buildTableCell('07:02'),
                                _buildTableCellWithBadge('17:10', 'LEMBUR'),
                              ],
                            ),
                            TableRow(
                              children: [
                                _buildTableCell('Lestari Ayu', isBold: true),
                                _buildTableCell('06:58'),
                                _buildTableCell('15:01'),
                              ],
                            ),
                            TableRow(
                              children: [
                                _buildTableCell('Rina Marlina', isBold: true),
                                _buildTableCell('07:15'),
                                _buildTableCell('15:05'),
                              ],
                            ),
                            TableRow(
                              children: [
                                _buildTableCell('Dimas Pratama', isBold: true),
                                _buildTableCell('11:55'),
                                _buildTableCell('-'),
                              ],
                            ),
                          ],
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
                          Icon(Icons.pie_chart_outline_rounded, size: 20, color: Utils.border),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Utils.border, width: 1.5),
                        ),
                        child: const Text(
                          '3 PRIORITAS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Utils.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2.5),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(1.5),
                      3: FlexColumnWidth(1.5),
                    },
                    border: const TableBorder(
                      horizontalInside: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                    ),
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
                        children: [
                          _buildTableCell('TUGAS', isHeader: true),
                          _buildTableCell('PENANGGUNG JAWAB', isHeader: true),
                          _buildTableCell('DEADLINE', isHeader: true),
                          _buildTableCell('STATUS', isHeader: true),
                        ],
                      ),
                      TableRow(
                        children: [
                          _buildTaskTableCell('Produksi roti tawar 200 pcs', Colors.blue),
                          _buildTableCell('Budi Santoso'),
                          _buildDateCell('21 Sep 2026'),
                          _buildStatusBadge('SEDANG DIKERJAKAN', Utils.primary, Colors.white),
                        ],
                      ),
                      TableRow(
                        children: [
                          _buildTaskTableCell('Pengemasan pesanan katering', Colors.grey),
                          _buildTableCell('Lestari Ayu'),
                          _buildDateCell('21 Sep 2026'),
                          _buildStatusBadge('BELUM MULAI', Colors.white, Utils.border, isOutline: true),
                        ],
                      ),
                      TableRow(
                        children: [
                          _buildTaskTableCell('Pengiriman pesanan toko', Utils.secondary),
                          _buildTableCell('Dimas Pratama'),
                          _buildDateCell('22 Sep 2026'),
                          _buildStatusBadge('DITINJAU', Utils.secondary, Utils.border),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
          BoxShadow(
            color: Utils.border,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Widget _buildWorkloadItem(String name, double factor, String percentageText, {bool isOverload = false}) {
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
            double barWidth = constraints.maxWidth * (factor > 1.0 ? 1.0 : factor);
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
                        const Icon(Icons.warning_amber_rounded, size: 12, color: Colors.white),
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

  Widget _buildTableCell(String text, {bool isHeader = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 11 : 13,
          fontWeight: isHeader
              ? FontWeight.w800
              : isBold
                  ? FontWeight.w700
                  : FontWeight.w500,
          color: isHeader ? const Color(0xFF666666) : Utils.border,
          letterSpacing: isHeader ? 0.5 : 0,
        ),
      ),
    );
  }

  Widget _buildTableCellWithBadge(String text, String badge) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Utils.border),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Utils.secondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Utils.border, width: 1),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: Utils.border,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTableCell(String text, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Utils.border,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCell(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 14, color: Utils.danger),
          const SizedBox(width: 6),
          Text(
            date,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Utils.border,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color bg, Color textCol, {bool isOutline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Utils.border, width: 1.5),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: textCol,
            ),
          ),
        ),
      ),
    );
  }
}
