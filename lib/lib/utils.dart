import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

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

  static const focusBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: primary),
  );

  static const errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: danger),
  );
}
