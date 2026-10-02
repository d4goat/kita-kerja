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

/// Widget wrapper preloader teks ASCII dengan cross-fade transition:
/// Preloader melakukan Fade-Out sementara halaman aplikasi melakukan Fade-In.
class AsciiPreloader extends StatefulWidget {
  /// Widget halaman utama / aplikasi yang berada di bawah preloader overlay.
  final Widget? child;

  /// Pola dasar ASCII tetap 10 karakter (default: "=++==-----").
  final String pattern;

  /// Fungsi asynchronous untuk pekerjaan inisialisasi nyata (mis. fetch token, DB, aset).
  final Future<void> Function()? onLoad;

  /// Callback yang dipanggil setelah animasi fade transition selesai.
  final VoidCallback? onFinished;

  /// Durasi minimum preloader tampil agar animasi tidak terpotong (default 1.5 detik).
  final Duration minDuration;

  /// Jeda diam pada frame akhir sebelum fade dimulai (default 200 ms).
  final Duration exitPauseDuration;

  /// Durasi animasi cross-fade saat transisi keluar (default 600 ms).
  final Duration fadeDuration;

  /// Kurva animasi cross-fade (default Curves.easeInOut).
  final Curve fadeCurve;

  /// Callback penanganan error saat [onLoad] gagal agar tidak macet di preloader.
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// Interval perpindahan frame animasi (default 100 ms / ~10 fps, rentang 80-120 ms).
  final Duration tickInterval;

  /// Ukuran font teks ASCII (default 22.0).
  final double fontSize;

  /// Jarak antar karakter teks ASCII (default 2.0).
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
    this.minDuration = const Duration(milliseconds: 1500),
    this.exitPauseDuration = const Duration(milliseconds: 200),
    this.fadeDuration = const Duration(milliseconds: 600),
    this.fadeCurve = Curves.easeInOut,
    this.onError,
    this.tickInterval = const Duration(milliseconds: 75),
    this.fontSize = 22.0,
    this.letterSpacing = -2.0,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<AsciiPreloader> createState() => _AsciiPreloaderState();
}

class _AsciiPreloaderState extends State<AsciiPreloader>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<String> _frameNotifier;
  late final AnimationController _fadeController;
  late final Animation<double> _overlayFadeAnimation;
  late final Animation<double> _childFadeAnimation;

  Timer? _rotationTimer;
  int _currentStep = 0;
  bool _isDisposed = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();

    // Inisialisasi frame pertama sesuai pattern
    _frameNotifier = ValueNotifier<String>(widget.pattern);

    // Controller untuk animasi cross-fade exit
    _fadeController = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );

    // Overlay memudar dari 1.0 ke 0.0
    _overlayFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: widget.fadeCurve),
    );

    // Konten aplikasi (child) muncul dari 0.0 ke 1.0
    _childFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: widget.fadeCurve),
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

      // Hentikan timer rotasi (bekukan frame pada posisi saat ini)
      _rotationTimer?.cancel();
      _rotationTimer = null;

      // Jeda diam sejenak pada frame terakhir
      if (widget.exitPauseDuration > Duration.zero) {
        await Future.delayed(widget.exitPauseDuration);
      }

      if (_isDisposed) return;

      // Jalankan animasi Cross-Fade (Overlay Fade-Out + Child Fade-In)
      await _fadeController.forward();

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

      // Tetap jalankan fade transition agar aplikasi tidak freeze
      await _fadeController.forward();
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
    _fadeController.dispose();
    _frameNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.backgroundColor ?? const Color.fromARGB(255, 195, 210, 255);
    final txtColor = widget.textColor ?? Utils.primary;

    final preloaderOverlay = Material(
      type: MaterialType.transparency,
      child: Container(
        color: bgColor,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
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
    );

    if (widget.child != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Konten halaman aplikasi yang memudar masuk (Fade-In)
          FadeTransition(
            opacity: _isFinished
                ? const AlwaysStoppedAnimation<double>(1.0)
                : _childFadeAnimation,
            child: widget.child!,
          ),

          // Overlay Preloader yang memudar keluar (Fade-Out)
          if (!_isFinished)
            FadeTransition(
              opacity: _overlayFadeAnimation,
              child: preloaderOverlay,
            ),
        ],
      );
    }

    return _isFinished
        ? const SizedBox.shrink()
        : FadeTransition(
            opacity: _overlayFadeAnimation,
            child: preloaderOverlay,
          );
  }
}
