import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Custom ScrollBehavior to enable trackpad, mouse, touch, and stylus dragging in Flutter Desktop & Web.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

/// Smooth Scroll wrapper for Flutter Web & Desktop.
/// Supports both physical mouse wheel smooth animation and native mousepad/trackpad panning.
class SmoothScrollWrapper extends StatefulWidget {
  final Widget child;
  final ScrollController? controller;

  const SmoothScrollWrapper({
    super.key,
    required this.child,
    this.controller,
  });

  @override
  State<SmoothScrollWrapper> createState() => _SmoothScrollWrapperState();
}

class _SmoothScrollWrapperState extends State<SmoothScrollWrapper> {
  late ScrollController _controller;
  bool _isLocalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = ScrollController();
      _isLocalController = true;
    }
  }

  @override
  void didUpdateWidget(SmoothScrollWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller && widget.controller != null) {
      if (_isLocalController) {
        _controller.dispose();
        _isLocalController = false;
      }
      _controller = widget.controller!;
    }
  }

  @override
  void dispose() {
    if (_isLocalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (!_controller.hasClients) return;

      final double dy = event.scrollDelta.dy;
      if (dy == 0) return;

      final double currentOffset = _controller.offset;
      final double maxScroll = _controller.position.maxScrollExtent;
      final double minScroll = _controller.position.minScrollExtent;

      final double targetOffset =
          (currentOffset + (dy * 1.5)).clamp(minScroll, maxScroll);

      _controller.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: AppScrollBehavior(),
      child: Listener(
        onPointerSignal: _handlePointerSignal,
        child: SingleChildScrollView(
          controller: _controller,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
