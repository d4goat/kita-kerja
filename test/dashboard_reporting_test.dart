import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kita_kerja/models/report_model.dart';
import 'package:kita_kerja/models/user_model.dart';
import 'package:kita_kerja/repositories/dashboard_repository.dart';
import 'package:kita_kerja/controllers/dashboard_controller.dart';
import 'package:kita_kerja/widgets/neo_charts.dart';

void main() {
  group('Dashboard Reporting - Model & Repository Test', () {
    late DashboardRepository dashboardRepo;

    setUp(() {
      dashboardRepo = DashboardRepository();
    });

    test('ReportFilter default values and copyWith function properly', () {
      final defaultFilter = const ReportFilter();
      expect(defaultFilter.period, 'this_month');
      expect(defaultFilter.groupBy, 'department');
      expect(defaultFilter.department, 'all');
      expect(defaultFilter.status, 'all');

      final updated = defaultFilter.copyWith(
        period: '30_days',
        groupBy: 'category',
        department: 'Teknologi Informasi',
        status: 'active',
      );
      expect(updated.period, '30_days');
      expect(updated.groupBy, 'category');
      expect(updated.department, 'Teknologi Informasi');
      expect(updated.status, 'active');
    });

    test('getReportData returns valid reporting data with fallback/db data', () async {
      final report = await dashboardRepo.getReportData(const ReportFilter());

      expect(report, isNotNull);
      expect(report.barChartData, isNotEmpty);
      expect(report.lineChartData, isNotEmpty);
      expect(report.pieChartData, isNotEmpty);
      expect(report.tableData, isNotEmpty);
      expect(report.summaryKPIs['total_tasks'], greaterThan(0));
      expect(report.summaryKPIs['completion_rate'], inInclusiveRange(0.0, 100.0));
    });

    test('getReportData handles different groupBy criteria (category, priority, status)', () async {
      // Group by Category
      final categoryReport = await dashboardRepo.getReportData(
        const ReportFilter(groupBy: 'category'),
      );
      expect(categoryReport.barChartData, isNotEmpty);
      expect(categoryReport.tableData, isNotEmpty);

      // Group by Priority
      final priorityReport = await dashboardRepo.getReportData(
        const ReportFilter(groupBy: 'priority'),
      );
      expect(priorityReport.barChartData, isNotEmpty);
      expect(priorityReport.tableData, isNotEmpty);

      // Group by Status
      final statusReport = await dashboardRepo.getReportData(
        const ReportFilter(groupBy: 'status'),
      );
      expect(statusReport.barChartData, isNotEmpty);
      expect(statusReport.tableData, isNotEmpty);
    });

    test('getReportData filters by department and period correctly', () async {
      final filteredReport = await dashboardRepo.getReportData(
        const ReportFilter(department: 'Teknologi', period: '7_days'),
      );
      expect(filteredReport, isNotNull);
      expect(filteredReport.barChartData, isNotEmpty);
      expect(filteredReport.lineChartData, isNotEmpty);
    });
  });

  group('Dashboard Reporting - Controller Test', () {
    late DashboardController controller;
    final testUser = UserModel(
      id: 1,
      name: 'Super Admin',
      email: 'admin@kitakerja.id',
      role: 'admin',
    );

    setUp(() {
      controller = DashboardController();
    });

    test('loadReport populates reportData and completes loading', () async {
      await controller.loadReport(testUser);

      expect(controller.isReportLoading, isFalse);
      expect(controller.reportData, isNotNull);
      expect(controller.reportData!.barChartData.length, greaterThan(0));
      expect(controller.reportData!.pieChartData.length, greaterThan(0));
      expect(controller.reportData!.lineChartData.length, greaterThan(0));
    });

    test('updateFilter triggers data refresh with new filter criteria', () async {
      await controller.loadReport(testUser);
      final initialGroupBy = controller.reportFilter.groupBy;
      expect(initialGroupBy, 'department');

      await controller.updateFilter(
        controller.reportFilter.copyWith(groupBy: 'category', period: '30_days'),
        testUser,
      );

      expect(controller.reportFilter.groupBy, 'category');
      expect(controller.reportFilter.period, '30_days');
      expect(controller.reportData, isNotNull);
      expect(controller.reportData!.activeFilter.groupBy, 'category');
    });
  });

  group('Dashboard Reporting - Chart Widgets Rendering Test', () {
    testWidgets('NeoBarChart renders without layout overflow or error', (WidgetTester tester) async {
      final sampleBars = [
        const BarChartItem(label: 'Teknologi Informasi', primaryValue: 15, secondaryValue: 12),
        const BarChartItem(label: 'SDM / HRD', primaryValue: 10, secondaryValue: 9),
        const BarChartItem(label: 'Pemasaran', primaryValue: 8, secondaryValue: 5),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NeoBarChart(
                title: 'Perbandingan Tugas per Departemen',
                items: sampleBars,
                primaryLegend: 'Total Tugas',
                secondaryLegend: 'Selesai',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(NeoBarChart), findsOneWidget);
      expect(find.text('Perbandingan Tugas per Departemen'), findsOneWidget);
      expect(find.text('Teknologi Informasi'), findsOneWidget);
      expect(find.text('SDM / HRD'), findsOneWidget);
      expect(find.text('Pemasaran'), findsOneWidget);
      expect(find.text('Total Tugas'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
    });

    testWidgets('NeoPieChart renders donut slices and legend elements', (WidgetTester tester) async {
      final sampleSlices = [
        const PieChartSlice(label: 'Selesai', value: 45, color: Color(0xFF00D26A)),
        const PieChartSlice(label: 'Sedang Dikerjakan', value: 30, color: Color(0xFFFFD028)),
        const PieChartSlice(label: 'Belum Mulai', value: 25, color: Color(0xFFFF4757)),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NeoPieChart(
                title: 'Distribusi Status Tugas',
                slices: sampleSlices,
                centerTitle: 'TOTAL',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(NeoPieChart), findsOneWidget);
      expect(find.text('Distribusi Status Tugas'), findsOneWidget);
      expect(find.text('TOTAL'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
      expect(find.text('Sedang Dikerjakan'), findsOneWidget);
      expect(find.text('Belum Mulai'), findsOneWidget);
    });

    testWidgets('NeoLineChart renders nodes, line polyline, and axis dates', (WidgetTester tester) async {
      final samplePoints = [
        const LineChartPoint(xLabel: '16 Nov', value: 18),
        const LineChartPoint(xLabel: '17 Nov', value: 20),
        const LineChartPoint(xLabel: '18 Nov', value: 22),
        const LineChartPoint(xLabel: '19 Nov', value: 19),
        const LineChartPoint(xLabel: '20 Nov', value: 24),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NeoLineChart(
                title: 'Tren Kehadiran Harian',
                points: samplePoints,
                lineLabel: 'Kehadiran Karyawan',
                valueSuffix: ' org',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(NeoLineChart), findsOneWidget);
      expect(find.text('Tren Kehadiran Harian'), findsOneWidget);
      expect(find.text('Kehadiran Karyawan'), findsOneWidget);
      expect(find.text('16 Nov'), findsOneWidget);
      expect(find.text('20 Nov'), findsOneWidget);
    });
  });
}
