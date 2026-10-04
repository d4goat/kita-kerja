import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kita_kerja/lib/utils.dart';

/// Fungsi murni (pure function) untuk memutar string secara melingkar ke KANAN sebanyak [steps] karakter.
///
/// Karakter terakhir dipindahkan ke posisi pertama untuk setiap step.
/// Contoh:
/// - rotateRight("++==--", 1) -> "-++==-"
/// - rotateRight("++==--", 2) -> "--++=="
/// - rotateRight("++==--", 3) -> "=--++="
String rotateRight(String s, int steps) {
  if (s.isEmpty) return s;
  final int n = s.length;
  final int shift = ((steps % n) + n) % n;
  if (shift == 0) return s;
  return s.substring(n - shift) + s.substring(0, n - shift);
}

/// Kurva transisi premium ala Framer Motion (CURVE_EASE: [0.76, 0, 0.24, 1])
const Curve curveEase = Cubic(0.76, 0.0, 0.24, 1.0);

/// Widget wrapper preloader teks ASCII dengan animasi exit slide-up dan bottom curve
/// terinspirasi dari preloader modern Next.js / Framer Motion.
class AsciiPreloader extends StatefulWidget {
  /// Widget halaman utama / aplikasi yang berada di bawah preloader overlay.
  final Widget? child;

  /// Pola dasar ASCII tetap (default: "=++==-+==--").
  final String pattern;

  /// Fungsi asynchronous untuk inisialisasi awal (mis. fetch token, koneksi DB, preload).
  final Future<void> Function()? onLoad;

  /// Callback yang dipanggil setelah animasi exit preloader selesai seutuhnya.
  final VoidCallback? onFinished;

  /// Durasi minimum preloader tampil agar animasi tidak terpotong (default 2.0 detik).
  final Duration minDuration;

  /// Jeda diam pada frame akhir sebelum animasi exit dimulai (default 300 ms).
  final Duration exitPauseDuration;

  /// Durasi total animasi exit slide-up (default 850 ms).
  final Duration exitDuration;

  /// Alias untuk [exitDuration] (backward compatibility).
  Duration get fadeDuration => exitDuration;

  /// Callback penanganan error saat [onLoad] gagal agar tidak macet di preloader.
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// Interval perpindahan frame rotasi ASCII (default 75 ms).
  final Duration tickInterval;

  /// Ukuran font teks ASCII (default 22.0).
  final double fontSize;

  /// Jarak antar karakter teks ASCII (default -2.0).
  final double letterSpacing;

  /// Warna latar belakang preloader (default: light blue / primary tint).
  final Color? backgroundColor;

  /// Warna teks ASCII (default: Utils.primary).
  final Color? textColor;

  const AsciiPreloader({
    super.key,
    this.child,
    this.pattern = '=++==-+==--',
    this.onLoad,
    this.onFinished,
    this.minDuration = const Duration(milliseconds: 2000),
    this.exitPauseDuration = const Duration(milliseconds: 300),
    Duration? exitDuration,
    Duration? fadeDuration,
    this.onError,
    this.tickInterval = const Duration(milliseconds: 75),
    this.fontSize = 22.0,
    this.letterSpacing = -2.0,
    this.backgroundColor,
    this.textColor,
  }) : exitDuration =
           exitDuration ?? fadeDuration ?? const Duration(milliseconds: 850);

  @override
  State<AsciiPreloader> createState() => _AsciiPreloaderState();
}

class _AsciiPreloaderState extends State<AsciiPreloader>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<String> _frameNotifier;
  late final AnimationController _exitController;

  // Animasi exit untuk teks loading (slide up singkat + fade out)
  late final Animation<Offset> _textSlideAnimation;
  late final Animation<double> _textFadeAnimation;

  // Animasi exit untuk tirai preloader overlay (slide up ke atas penuh)
  late final Animation<Offset> _curtainSlideAnimation;

  // Animasi lengkungan elastis di bagian bawah tirai saat ditarik ke atas
  late final Animation<double> _curveAnimation;

  // Animasi enter untuk konten utama (child) yang tersingkap (slide up halus + fade in)
  late final Animation<Offset> _childSlideAnimation;
  late final Animation<double> _childFadeAnimation;

  Timer? _rotationTimer;
  int _currentStep = 0;
  bool _isDisposed = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();

    _frameNotifier = ValueNotifier<String>(widget.pattern);

    _exitController = AnimationController(
      vsync: this,
      duration: widget.exitDuration,
    );

    // 1. Teks ASCII: Slide up cepat (-60px setara Offset(0, -1.8)) & Fade Out di awal exit (0.0 -> 0.35)
    _textSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -1.8)).animate(
          CurvedAnimation(
            parent: _exitController,
            curve: const Interval(0.0, 0.35, curve: curveEase),
          ),
        );

    _textFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    // 2. Tirai Preloader (Curtain): Meluncur ke atas (Offset(0, 0) -> Offset(0, -1.0)) setelah jeda singkat (0.15 -> 1.0)
    _curtainSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -1.0)).animate(
          CurvedAnimation(
            parent: _exitController,
            curve: const Interval(0.15, 1.0, curve: curveEase),
          ),
        );

    // 3. Lengkungan Bawah Tirai (Bottom Curve): mengembang dari 0 ke puncak lalu merata kembali saat slide selesai
    _curveAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOutQuad)),
            weight: 35.0,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 1.0,
              end: 0.0,
            ).chain(CurveTween(curve: Curves.easeInQuad)),
            weight: 65.0,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _exitController,
            curve: const Interval(0.15, 0.95),
          ),
        );

    // 4. Konten Utama (Child): Slide up lembut dari Offset(0, 0.06) ke Offset.zero & Fade-In berkesinambungan
    _childSlideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _exitController,
            curve: const Interval(0.20, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _childFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: const Interval(0.15, 0.85, curve: Curves.easeIn),
      ),
    );

    _startRotationTimer();
    _startPreloadProcess();
  }

  void _startRotationTimer() {
    _rotationTimer = Timer.periodic(widget.tickInterval, (_) {
      _currentStep++;
      _frameNotifier.value = rotateRight(widget.pattern, _currentStep);
    });
  }

  Future<void> _startPreloadProcess() async {
    final minDurationFuture = Future.delayed(widget.minDuration);
    Future<void>? loadFuture;

    if (widget.onLoad != null) {
      loadFuture = widget.onLoad!();
    }

    try {
      if (loadFuture != null) {
        await Future.wait([minDurationFuture, loadFuture]);
      } else {
        await minDurationFuture;
      }

      if (_isDisposed) return;

      // Hentikan rotasi string pada frame terakhir
      _rotationTimer?.cancel();
      _rotationTimer = null;

      // Jeda diam sejenak sebelum exit
      if (widget.exitPauseDuration > Duration.zero) {
        await Future.delayed(widget.exitPauseDuration);
      }

      if (_isDisposed) return;

      // Jalankan animasi exit slide-up
      await _exitController.forward();

      if (!_isDisposed) {
        setState(() {
          _isFinished = true;
        });
        widget.onFinished?.call();
      }
    } catch (error, stackTrace) {
      if (_isDisposed) return;
      _rotationTimer?.cancel();
      _rotationTimer = null;

      if (widget.onError != null) {
        widget.onError!(error, stackTrace);
      }

      // Tetap jalankan exit transition agar tidak stuck
      await _exitController.forward();
      if (!_isDisposed) {
        setState(() {
          _isFinished = true;
        });
        widget.onFinished?.call();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _rotationTimer?.cancel();
    _rotationTimer = null;
    _exitController.dispose();
    _frameNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.backgroundColor ?? const Color.fromARGB(255, 195, 210, 255);
    final txtColor = widget.textColor ?? Utils.primary;

    // Overlay tirai preloader yang melakukan slide-up ke atas
    final preloaderOverlay = SlideTransition(
      position: _curtainSlideAnimation,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          // Background tirai utama
          Container(
            color: bgColor,
            alignment: Alignment.center,
            child: FadeTransition(
              opacity: _textFadeAnimation,
              child: SlideTransition(
                position: _textSlideAnimation,
                child: ValueListenableBuilder<String>(
                  valueListenable: _frameNotifier,
                  builder: (context, frameText, _) {
                    return Text(
                      frameText,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: widget.letterSpacing,
                        color: txtColor,
                        decoration: TextDecoration.none,
                        shadows: [
                          Shadow(
                            color: txtColor.withValues(alpha: 0.5),
                            blurRadius: 10.0,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Lengkungan bawah tirai (Bottom curve saat ditarik ke atas)
          Positioned(
            left: 0,
            right: 0,
            bottom: -140.0,
            height: 140.0,
            child: AnimatedBuilder(
              animation: _curveAnimation,
              builder: (context, _) {
                final double currentCurveHeight = _curveAnimation.value * 140.0;
                return CustomPaint(
                  size: const Size(double.infinity, 140.0),
                  painter: _CurvedBottomCurtainPainter(
                    color: bgColor,
                    curveHeight: currentCurveHeight,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    if (widget.child != null) {
      return Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          // Konten halaman aplikasi utama (Enter animation: Slide Up halus + Fade In)
          if (_isFinished)
            widget.child!
          else
            FadeTransition(
              opacity: _childFadeAnimation,
              child: SlideTransition(
                position: _childSlideAnimation,
                child: widget.child!,
              ),
            ),

          // Overlay Preloader
          if (!_isFinished) preloaderOverlay,
        ],
      );
    }

    return _isFinished ? const SizedBox.shrink() : preloaderOverlay;
  }
}

/// CustomPainter untuk menggambar lengkungan di bawah tirai saat ditarik meluncur ke atas
class _CurvedBottomCurtainPainter extends CustomPainter {
  final Color color;
  final double curveHeight;

  const _CurvedBottomCurtainPainter({
    required this.color,
    required this.curveHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (curveHeight <= 0.1) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..quadraticBezierTo(size.width * 0.5, curveHeight, 0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvedBottomCurtainPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.curveHeight != curveHeight;
  }
}
