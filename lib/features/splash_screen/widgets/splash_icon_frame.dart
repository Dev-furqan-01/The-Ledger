import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SplashIconFrame extends StatelessWidget {
  const SplashIconFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.onBackground.withOpacity(0.04),
            offset: const Offset(0, 12),
            blurRadius: 24,
          ),
        ],
      ),
      child: Center(
        child: ClipOval(
          child: Image.asset(
            'assets/images/hand icon.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: AppColors.primary,
              );
            },
          ),
        ),
      ),
    );
  }
}
