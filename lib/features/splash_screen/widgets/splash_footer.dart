import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/splash_content.dart';

class SplashFooter extends StatefulWidget {
  final SplashContent content;
  const SplashFooter({super.key, required this.content});

  @override
  State<SplashFooter> createState() => _SplashFooterState();
}

class _SplashFooterState extends State<SplashFooter>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 3.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Pulse circle
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: (1.0 - (_pulseController.value)).clamp(0.0, 0.2),
                  child: Container(
                    width: 16 * _pulseAnimation.value,
                    height: 16 * _pulseAnimation.value,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
            // Central dot
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          widget.content.statusText,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.onSurfaceVariant.withOpacity(0.5),
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }
}
