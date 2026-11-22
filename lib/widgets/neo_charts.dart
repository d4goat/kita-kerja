import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/core/utils/utils.dart';
import 'package:kita_kerja/models/report_model.dart';

// =============================================================================
// 1. NEO BAR CHART (Grafik Batang Neo-Brutalism)
// =============================================================================

class NeoBarChart extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<BarChartItem> items;
  final String primaryLegend;
  final String? secondaryLegend;
  final Color primaryColor;
  final Color secondaryColor;
  final double height;
  final String valueSuffix;

  const NeoBarChart({
    super.key,
    required this.title,
    this.subtitle,
    required this.items,
    this.primaryLegend = 'Total',
    this.secondaryLegend,
    this.primaryColor = Utils.neoBlue,
    this.secondaryColor = Utils.neoGreen,
    this.height = 280,
    this.valueSuffix = '',
  });

  @override
  Widget build(BuildContext context) {
    double maxValue = 0;
    for (var item in items) {
      if (item.primaryValue > maxValue) maxValue = item.primaryValue;
      if (item.secondaryValue != null && item.secondaryValue! > maxValue) {
        maxValue = item.secondaryValue!;
      }
    }
    if (maxValue == 0) maxValue = 10;
    // Bulatkan max value ke atas untuk skala Y
    final yMax = ((maxValue / 5).ceil() * 5).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Utils.neoCream,
        border: Utils.borderW,
        boxShadow: Utils.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Legenda
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Utils.neoBlack,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Utils.neoBlack.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Wrap(
                spacing: 12,
                children: [
                  _buildLegendItem(primaryLegend, primaryColor),
                  if (secondaryLegend != null)
                    _buildLegendItem(secondaryLegend!, secondaryColor),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Area Bar Chart
          SizedBox(
            height: height,
            child: items.isEmpty
                ? const Center(
                    child: Text('Tidak ada data untuk grafik batang.'),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Sumbu Y
                          SizedBox(
                            width: 36,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${yMax.toInt()}', style: _axisStyle),
                                Text('${(yMax * 0.75).toInt()}', style: _axisStyle),
                                Text('${(yMax * 0.5).toInt()}', style: _axisStyle),
                                Text('${(yMax * 0.25).toInt()}', style: _axisStyle),
                                Text('0', style: _axisStyle),
                                const SizedBox(height: 24), // Offset label X
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Area Grid & Batang
                          Expanded(
                            child: Stack(
                              children: [
                                // Garis Panduan Horizontal
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(5, (index) {
                                    return Container(
                                      height: 1,
                                      color: Utils.neoBlack.withOpacity(0.12),
                                    );
                                  }),
                                ),

                                // Kolom Batang
                                Positioned.fill(
                                  bottom: 24,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final availableHeight = constraints.maxHeight - 24;
                                      final safeHeight = availableHeight > 10 ? availableHeight : 100.0;

                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: items.map((item) {
                                          final pFactor = (item.primaryValue / yMax).clamp(0.0, 1.0);
                                          final sFactor = item.secondaryValue != null
                                              ? (item.secondaryValue! / yMax).clamp(0.0, 1.0)
                                              : 0.0;

                                          final pHeight = (safeHeight * pFactor).clamp(4.0, safeHeight);
                                          final sHeight = (safeHeight * sFactor).clamp(4.0, safeHeight);

                                          return Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  // Nilai di atas batang
                                                  Text(
                                                    item.secondaryValue != null
                                                        ? '${item.primaryValue.toInt()}/${item.secondaryValue!.toInt()}'
                                                        : '${item.primaryValue.toInt()}$valueSuffix',
                                                    style: GoogleFonts.spaceGrotesk(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                      color: Utils.neoBlack,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),

                                                  // Pasangan Batang
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      // Bar Primer
                                                      Container(
                                                        height: pHeight,
                                                        width: item.secondaryValue != null ? 18 : 28,
                                                        decoration: BoxDecoration(
                                                          color: item.color ?? primaryColor,
                                                          border: Utils.borderWSm,
                                                          boxShadow: Utils.shadowSm,
                                                        ),
                                                      ),

                                                      // Bar Sekunder (jika ada)
                                                      if (item.secondaryValue != null) ...[
                                                        const SizedBox(width: 4),
                                                        Container(
                                                          height: sHeight,
                                                          width: 18,
                                                          decoration: BoxDecoration(
                                                            color: secondaryColor,
                                                            border: Utils.borderWSm,
                                                            boxShadow: Utils.shadowSm,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ),

                                // Label Sumbu X di bagian bawah
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  height: 20,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: items.map((item) {
                                      return Expanded(
                                        child: Text(
                                          item.label,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Utils.neoBlack,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  TextStyle get _axisStyle => GoogleFonts.spaceGrotesk(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Utils.neoBlack.withOpacity(0.7),
      );

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            border: Utils.borderWSm,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Utils.neoBlack,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 2. NEO LINE CHART (Grafik Garis / Tren Neo-Brutalism)
// =============================================================================

class NeoLineChart extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<LineChartPoint> points;
  final String lineLabel;
  final Color lineColor;
  final double height;
  final String valueSuffix;

  const NeoLineChart({
    super.key,
    required this.title,
    this.subtitle,
    required this.points,
    this.lineLabel = 'Tren',
    this.lineColor = Utils.neoBlue,
    this.height = 280,
    this.valueSuffix = '',
  });

  @override
  Widget build(BuildContext context) {
    double maxValue = 0;
    for (var p in points) {
      if (p.value > maxValue) maxValue = p.value;
    }
    if (maxValue == 0) maxValue = 10;
    final yMax = ((maxValue / 5).ceil() * 5).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Utils.neoCream,
        border: Utils.borderW,
        boxShadow: Utils.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Legenda
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Utils.neoBlack,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Utils.neoBlack.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 4,
                    color: lineColor,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Utils.neoYellow,
                      border: Utils.borderWSm,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    lineLabel,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Utils.neoBlack,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Area Canvas Grafik Garis
          SizedBox(
            height: height,
            child: points.isEmpty
                ? const Center(
                    child: Text('Tidak ada data untuk grafik garis.'),
                  )
                : Row(
                    children: [
                      // Label Sumbu Y
                      SizedBox(
                        width: 36,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${yMax.toInt()}', style: _axisStyle),
                            Text('${(yMax * 0.75).toInt()}', style: _axisStyle),
                            Text('${(yMax * 0.5).toInt()}', style: _axisStyle),
                            Text('${(yMax * 0.25).toInt()}', style: _axisStyle),
                            Text('0', style: _axisStyle),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Area CustomPaint Grafik
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: _NeoLineChartPainter(
                                  points: points,
                                  yMax: yMax,
                                  lineColor: lineColor,
                                  valueSuffix: valueSuffix,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Sumbu X
                            SizedBox(
                              height: 18,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: points.map((p) {
                                  return Text(
                                    p.xLabel,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Utils.neoBlack,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  TextStyle get _axisStyle => GoogleFonts.spaceGrotesk(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Utils.neoBlack.withOpacity(0.7),
      );
}

class _NeoLineChartPainter extends CustomPainter {
  final List<LineChartPoint> points;
  final double yMax;
  final Color lineColor;
  final String valueSuffix;

  _NeoLineChartPainter({
    required this.points,
    required this.yMax,
    required this.lineColor,
    required this.valueSuffix,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // 1. Gambar Garis Grid Horizontal
    final gridPaint = Paint()
      ..color = Utils.neoBlack.withOpacity(0.12)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4.0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Hitung Titik Koordinat
    final double stepX = points.length > 1
        ? size.width / (points.length - 1)
        : size.width / 2;

    final List<Offset> coords = [];
    for (int i = 0; i < points.length; i++) {
      final x = points.length == 1 ? size.width / 2 : i * stepX;
      final yFactor = (points[i].value / yMax).clamp(0.0, 1.0);
      final y = size.height - (yFactor * size.height);
      coords.add(Offset(x, y));
    }

    // 3. Area Fill di bawah garis (gradient transparan)
    final path = Path();
    path.moveTo(coords.first.dx, size.height);
    path.lineTo(coords.first.dx, coords.first.dy);
    for (int i = 1; i < coords.length; i++) {
      path.lineTo(coords[i].dx, coords[i].dy);
    }
    path.lineTo(coords.last.dx, size.height);
    path.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withOpacity(0.35),
          lineColor.withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, fillPaint);

    // 4. Garis Polyline Utama
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    linePath.moveTo(coords.first.dx, coords.first.dy);
    for (int i = 1; i < coords.length; i++) {
      linePath.lineTo(coords[i].dx, coords[i].dy);
    }
    canvas.drawPath(linePath, strokePaint);

    // 5. Node Titik Data & Nilai
    final pointBorderPaint = Paint()
      ..color = Utils.neoBlack
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final pointFillPaint = Paint()
      ..color = Utils.neoYellow
      ..style = PaintingStyle.fill;

    for (int i = 0; i < coords.length; i++) {
      final p = coords[i];
      // Gambar lingkaran titik
      canvas.drawCircle(p, 5.5, pointFillPaint);
      canvas.drawCircle(p, 5.5, pointBorderPaint);

      // Gambar Teks Nilai di atas titik
      final textSpan = TextSpan(
        text: '${points[i].value.toStringAsFixed(points[i].value % 1 == 0 ? 0 : 1)}$valueSuffix',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Utils.neoBlack,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(p.dx - (textPainter.width / 2), p.dy - textPainter.height - 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NeoLineChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.yMax != yMax;
  }
}

// =============================================================================
// 3. NEO PIE / DONUT CHART (Grafik Lingkaran Neo-Brutalism)
// =============================================================================

class NeoPieChart extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<PieChartSlice> slices;
  final double height;
  final String centerTitle;

  const NeoPieChart({
    super.key,
    required this.title,
    this.subtitle,
    required this.slices,
    this.height = 280,
    this.centerTitle = 'TOTAL',
  });

  @override
  Widget build(BuildContext context) {
    final double totalValue = slices.fold(0.0, (sum, item) => sum + item.value);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Utils.neoCream,
        border: Utils.borderW,
        boxShadow: Utils.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Utils.neoBlack,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Utils.neoBlack.withOpacity(0.8),
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Area Pie & Legenda (Berdampingan)
          SizedBox(
            height: height,
            child: slices.isEmpty || totalValue == 0
                ? const Center(
                    child: Text('Tidak ada data untuk grafik lingkaran.'),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 450;
                      if (isNarrow) {
                        return Column(
                          children: [
                            Expanded(child: _buildPieVisual(totalValue)),
                            const SizedBox(height: 12),
                            _buildLegendList(totalValue),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          // Lingkaran Pie Donut
                          Expanded(
                            flex: 5,
                            child: _buildPieVisual(totalValue),
                          ),
                          const SizedBox(width: 24),

                          // Daftar Legenda Komposisi
                          Expanded(
                            flex: 6,
                            child: _buildLegendList(totalValue),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieVisual(double totalValue) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(190, 190),
          painter: _NeoPieChartPainter(
            slices: slices,
            totalValue: totalValue,
          ),
        ),
        // Tengah Donut: Total Angka & Label
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              totalValue.toInt().toString(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Utils.neoBlack,
              ),
            ),
            Text(
              centerTitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Utils.neoBlack.withOpacity(0.7),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendList(double totalValue) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: slices.map((slice) {
          final pct = slice.percentageOf(totalValue);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                // Kotak Warna Border
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: slice.color,
                    border: Utils.borderWSm,
                    boxShadow: Utils.shadowSm,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    slice.label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Utils.neoBlack,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: const BoxDecoration(
                    color: Utils.neoBlack,
                  ),
                  child: Text(
                    '${slice.value.toInt()} (${pct.toStringAsFixed(1)}%)',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Utils.neoCream,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NeoPieChartPainter extends CustomPainter {
  final List<PieChartSlice> slices;
  final double totalValue;

  _NeoPieChartPainter({
    required this.slices,
    required this.totalValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalValue <= 0 || slices.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final holeRadius = radius * 0.54;

    double startAngle = -math.pi / 2;

    final borderPaint = Paint()
      ..color = Utils.neoBlack
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    for (var slice in slices) {
      if (slice.value <= 0) continue;
      final sweepAngle = (slice.value / totalValue) * 2 * math.pi;

      // Gambar irisan slice
      fillPaint.color = slice.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        fillPaint,
      );

      // Gambar pembatas irisan
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    }

    // Lubang Donut Tengah (NeoCream background)
    final holeFillPaint = Paint()
      ..color = Utils.neoCream
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, holeRadius, holeFillPaint);
    canvas.drawCircle(center, holeRadius, borderPaint);

    // Garis Luar Lingkaran Penuh
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _NeoPieChartPainter oldDelegate) {
    return oldDelegate.slices != slices || oldDelegate.totalValue != totalValue;
  }
}
