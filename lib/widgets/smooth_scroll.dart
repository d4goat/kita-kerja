import 'package:dyn_mouse_scroll/dyn_mouse_scroll.dart';
import 'package:flutter/material.dart';

/// Smooth Scroll wrapper menggunakan DynMouseScroll untuk Flutter Web & Desktop.
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
