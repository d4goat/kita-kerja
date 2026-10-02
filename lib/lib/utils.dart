import 'package:flutter/material.dart';
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

  static double? get widthSize {
    return screenWidth;
  }

  static double? get heigthSize {
    return screenHeigth;
  }

  static final logger = Logger();

  static final smallSpace = const SizedBox(height: 25);
  static SizedBox get mediumSpace =>
      SizedBox(height: (screenHeigth ?? 0) * 0.05);
  static SizedBox get bigSpace => SizedBox(height: (screenHeigth ?? 0) * 0.08);

  static const outlinedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6)),
  );

  static const Color background = Color(0xFFF5F1E8);
  static const Color border = Color(0xFF111111);
  static const Color primary = Color(0xFF315CFF);
  static const Color secondary = Color(0xFFF5C542);
  static const Color success = Color(0xFF35C759);
  static const Color danger = Color(0xFFFF5A5F);
  static const Color mainBackground = Color(0xFFFFF4F4);

  static String formatRupiah(num amount) {
    String str = amount.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formatted = str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  static const focusBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: primary),
  );

  static const errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: danger),
  );

  static void toast(
    BuildContext context,
    String title,
    ToastificationType type,
    IconData icon,
    dynamic theme,
  ) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: const Duration(seconds: 4),
      title: Text(title, style: TextStyle(color: theme)),
      alignment: Alignment.topRight,
      direction: TextDirection.ltr,
      icon: Icon(icon, color: theme),
      showIcon: true,
      primaryColor: Colors.white,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 16,
          offset: Offset(0, 16),
          spreadRadius: 0,
        ),
      ],
      showProgressBar: true,
      progressBarTheme: ProgressIndicatorThemeData(color: theme),
      closeButton: ToastCloseButton(
        showType: CloseButtonShowType.onHover,
        buttonBuilder: (context, onClose) {
          return OutlinedButton.icon(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 20),
            label: const Text('Close'),
          );
        },
      ),
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
      onHoverMouseCursor: SystemMouseCursors.click,
    );
  }
}
