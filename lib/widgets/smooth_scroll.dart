import 'package:dyn_mouse_scroll/dyn_mouse_scroll.dart';
import 'package:flutter/material.dart';

/// Smooth Scroll wrapper for Flutter Web & Desktop using `dyn_mouse_scroll`.
/// Provides physics-driven, ultra-smooth mouse wheel scrolling.
class SmoothScrollWrapper extends StatelessWidget {
  final Widget child;

  const SmoothScrollWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DynMouseScroll(
      builder: (context, scrollController, physics) {
        return SingleChildScrollView(
          controller: scrollController,
          physics: physics,
          child: child,
        );
      },
    );
  }
}
