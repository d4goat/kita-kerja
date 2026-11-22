import 'package:flutter/material.dart';

/// Model untuk konfigurasi filter dan pengelompokan laporan data
class ReportFilter {
  final String period; // 'this_month', '30_days', '7_days', 'all'
  final String department; // 'all' atau nama/id departemen
  final String groupBy; // 'department', 'category', 'priority', 'status'
  final String status; // 'all', 'active', 'completed'

  const ReportFilter({
    this.period = 'this_month',
    this.department = 'all',
    this.groupBy = 'department',
    this.status = 'all',
  });

  String get periodLabel {
    switch (period) {
      case '7_days':
        return '7 Hari Terakhir';
      case '30_days':
        return '30 Hari Terakhir';
      case 'this_month':
        return 'Bulan Ini';
      case 'all':
      default:
        return 'Semua Periode';
    }
  }

  String get groupByLabel {
    switch (groupBy) {
      case 'category':
        return 'Kategori Pekerjaan';
      case 'priority':
        return 'Prioritas Tugas';
      case 'status':
        return 'Status Pengerjaan';
      case 'department':
      default:
        return 'Departemen Tim';
    }
  }

  ReportFilter copyWith({
    String? period,
    String? department,
    String? groupBy,
    String? status,
  }) {
    return ReportFilter(
      period: period ?? this.period,
      department: department ?? this.department,
      groupBy: groupBy ?? this.groupBy,
      status: status ?? this.status,
    );
  }
}

/// Data item untuk Bar Chart (Grafik Batang)
class BarChartItem {
  final String label;
  final double primaryValue;
  final double? secondaryValue;
  final Color? color;

  const BarChartItem({
    required this.label,
    required this.primaryValue,
    this.secondaryValue,
    this.color,
  });
}

/// Data item untuk Line Chart (Grafik Garis / Tren)
class LineChartPoint {
  final String xLabel;
  final double value;
  final double? secondaryValue;
  final String? tooltip;

  const LineChartPoint({
    required this.xLabel,
    required this.value,
    this.secondaryValue,
    this.tooltip,
  });
}

/// Data item untuk Pie Chart (Grafik Lingkaran / Donut)
class PieChartSlice {
  final String label;
  final double value;
  final Color color;
  final IconData? icon;

  const PieChartSlice({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });

  double percentageOf(double total) =>
      total > 0 ? (value / total) * 100.0 : 0.0;
}

/// Baris ringkasan tabel laporan
class ReportTableRowData {
  final String groupName;
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final double totalEstimatedHours;
  final double totalActualHours;
  final double completionRate;

  const ReportTableRowData({
    required this.groupName,
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.totalEstimatedHours,
    required this.totalActualHours,
    required this.completionRate,
  });
}

/// Kumpulan lengkap data reporting hasil query database
class DashboardReportData {
  final ReportFilter activeFilter;
  final List<BarChartItem> barChartData;
  final List<LineChartPoint> lineChartData;
  final List<PieChartSlice> pieChartData;
  final List<ReportTableRowData> tableData;
  final Map<String, dynamic> summaryKPIs;

  const DashboardReportData({
    required this.activeFilter,
    required this.barChartData,
    required this.lineChartData,
    required this.pieChartData,
    required this.tableData,
    required this.summaryKPIs,
  });
}
