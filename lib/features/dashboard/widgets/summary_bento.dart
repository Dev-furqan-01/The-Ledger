import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';

class SummaryBento extends StatelessWidget {
  final List<TransactionModel> transactions;

  const SummaryBento({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    double totalCredit = 0;
    double totalDebit = 0;

    for (var tx in transactions) {
      if (tx.type == TransactionType.credit) {
        totalCredit += tx.amount;
      } else {
        totalDebit += tx.amount;
      }
    }

    final currencyFormat = NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Row(
      children: [
        Expanded(
          child: _BentoCard(
            title: 'TOTAL CREDIT',
            amount: currencyFormat.format(totalCredit),
            percentage: '+${_calculatePercentage(totalCredit, totalDebit)}%',
            icon: Icons.trending_up,
            iconColor: AppColors.onTertiaryContainer,
            containerColor: AppColors.tertiaryContainer.withOpacity(0.05),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _BentoCard(
            title: 'TOTAL DEBIT',
            amount: currencyFormat.format(totalDebit),
            percentage: '-${_calculatePercentage(totalDebit, totalCredit)}%',
            icon: Icons.trending_down,
            iconColor: AppColors.error,
            containerColor: AppColors.errorContainer.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  String _calculatePercentage(double target, double other) {
    if (target + other == 0) return '0';
    return ((target / (target + other)) * 100).toStringAsFixed(0);
  }
}

class _BentoCard extends StatelessWidget {
  final String title;
  final String amount;
  final String percentage;
  final IconData icon;
  final Color iconColor;
  final Color containerColor;

  const _BentoCard({
    required this.title,
    required this.amount,
    required this.percentage,
    required this.icon,
    required this.iconColor,
    required this.containerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              Text(
                percentage,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$$amount',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
          ),
        ],
      ),
    );
  }
}
