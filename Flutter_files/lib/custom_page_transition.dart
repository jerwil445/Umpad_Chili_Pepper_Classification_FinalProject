import 'package:flutter/material.dart';

class CustomPageTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Combine fade and slide transition with smoother curve
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0), // Start from right
        end: Offset.zero, // End at normal position
      ).animate(curvedAnimation),
      child: FadeTransition(opacity: curvedAnimation, child: child),
    );
  }
}
