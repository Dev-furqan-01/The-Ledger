import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  static const RadialGradient splashGradient = RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: [
      Colors.white,
      AppColors.surfaceContainerLow,
    ],
  );
}
