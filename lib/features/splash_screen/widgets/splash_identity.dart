import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/splash_content.dart';

class SplashIdentity extends StatelessWidget {
  final SplashContent content;
  const SplashIdentity({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          content.title,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content.subtitle,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.outline.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
