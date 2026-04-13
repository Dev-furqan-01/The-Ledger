import 'package:flutter/material.dart';

class AppGradients {
  static RadialGradient getSplashGradient(ColorScheme colorScheme) {
    return RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        colorScheme.surface,
        colorScheme.surfaceContainerLow,
      ],
    );
  }
}
