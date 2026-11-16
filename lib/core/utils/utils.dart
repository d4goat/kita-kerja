import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:toastification/toastification.dart';

class Utils {
  static MediaQueryData? mediaQueryData;
  static double? screenWidth;
  static double? screenHeigth;

  void init(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData!.size.width;
    screenHeigth = mediaQueryData!.size.height;
  }

  static double? get widthSize => screenWidth;
  static double? get heigthSize => screenHeigth;

  static final logger = Logger();

  static const smallSpace = SizedBox(height: 24);
  static SizedBox get mediumSpace =>
      SizedBox(height: (screenHeigth ?? 0) * 0.04);
  static SizedBox get bigSpace => SizedBox(height: (screenHeigth ?? 0) * 0.08);

  // 1. Tokens - Warna (HANYA 6 WARNA MUTLAK)
  static const Color neoBlack = Color(0xFF111111);
  static const Color neoCream = Color(0xFFF5F1E8);
  static const Color neoBlue = Color(0xFF315CFF);
  static const Color neoYellow = Color(0xFFF5C542);
  static const Color neoGreen = Color(0xFF35C759);
  static const Color neoRed = Color(0xFFFF5A5F);

  // Aliases for compatibility
  static const Color background = neoCream;
  static const Color border = neoBlack;
  static const Color primary = neoBlue;
  static const Color secondary = neoYellow;
  static const Color success = neoGreen;
  static const Color danger = neoRed;
  static const Color warning = neoYellow;
  static const Color mainBackground = neoCream;

  // 2. Tokens - Border
  static const BorderSide borderSideW = BorderSide(color: neoBlack, width: 3.0);
  static const BorderSide borderSideWSm = BorderSide(color: neoBlack, width: 2.0);
  static const Border borderW = Border.fromBorderSide(borderSideW);
  static const Border borderWSm = Border.fromBorderSide(borderSideWSm);

  static const outlinedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: borderSideW,
  );

  static const focusBorder = OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: borderSideW,
  );

  static const errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: borderSideW,
  );

  // 3. Tokens - Hard Shadow (blur 0, spread 0, solid black)
  static const List<BoxShadow> shadowNone = [];
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: neoBlack, offset: Offset(2, 2), blurRadius: 0, spreadRadius: 0),
  ];
  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: neoBlack, offset: Offset(4, 4), blurRadius: 0, spreadRadius: 0),
  ];
  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: neoBlack, offset: Offset(6, 6), blurRadius: 0, spreadRadius: 0),
  ];
  static const List<BoxShadow> shadowXl = [
    BoxShadow(color: neoBlack, offset: Offset(8, 8), blurRadius: 0, spreadRadius: 0),
  ];

  // 4. Tokens - Typography (Space Grotesk & Inter)
  static TextStyle fontDisplay({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w700,
    Color color = neoBlack,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle fontUi({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color color = neoBlack,
    double? height,
    double? letterSpacing,
    List<FontFeature>? fontFeatures,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontFeatures: fontFeatures ?? const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle get textKpi => fontDisplay(fontSize: 48, fontWeight: FontWeight.w700);
  static TextStyle get textH1 => fontDisplay(fontSize: 32, fontWeight: FontWeight.w700);
  static TextStyle get textH2 => fontDisplay(fontSize: 24, fontWeight: FontWeight.w700);
  static TextStyle get textH3 => fontDisplay(fontSize: 18, fontWeight: FontWeight.w700);
  static TextStyle get textBody => fontUi(fontSize: 14, fontWeight: FontWeight.w500);
  static TextStyle get textBodyStrong => fontUi(fontSize: 14, fontWeight: FontWeight.w700);
  static TextStyle get textLabel => fontUi(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5);
  static TextStyle get textCaption => fontUi(fontSize: 12, fontWeight: FontWeight.w500);

  static String formatRupiah(num amount) {
    String str = amount.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formatted = str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  // Neobrutalist Toast Notification
  static void toast(
    BuildContext context,
    String title,
    ToastificationType type,
    IconData icon,
    dynamic theme,
  ) {
    Color bg = neoCream;
    Color fg = neoBlack;
    if (type == ToastificationType.error) {
      bg = neoRed;
      fg = neoBlack;
    } else if (type == ToastificationType.success) {
      bg = neoGreen;
      fg = neoBlack;
    } else if (type == ToastificationType.warning) {
      bg = neoYellow;
      fg = neoBlack;
    } else {
      bg = neoCream;
      fg = neoBlack;
    }

    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: const Duration(seconds: 4),
      title: Text(
        title,
        style: fontUi(fontSize: 13, fontWeight: FontWeight.w700, color: fg),
      ),
      alignment: Alignment.topRight,
      direction: TextDirection.ltr,
      icon: Icon(icon, color: fg, size: 20),
      showIcon: true,
      primaryColor: bg,
      backgroundColor: bg,
      foregroundColor: fg,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: BorderRadius.zero,
      borderSide: borderSideW,
      boxShadow: shadowXl,
      showProgressBar: false,
      closeButton: ToastCloseButton(
        showType: CloseButtonShowType.always,
        buttonBuilder: (context, onClose) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: neoCream,
                  border: Border.all(color: neoBlack, width: 2),
                ),
                child: const Icon(Icons.close, size: 16, color: neoBlack),
              ),
            ),
          );
        },
      ),
    );
  }
}
