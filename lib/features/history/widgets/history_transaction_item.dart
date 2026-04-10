import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../dashboard/models/transaction_model.dart';
import 'package:intl/intl.dart';

class HistoryTransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const HistoryTransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNegative = transaction.type == TransactionType.debit;
    final Color accentColor = isNegative ? AppColors.error : AppColors.secondary;
    final String amount = transaction.amount.toStringAsFixed(2);
    final String time = DateFormat('HH:mm a').format(transaction.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1D).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(transaction.icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 16,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        transaction.category.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isNegative ? '-' : '+'} \$$amount',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                        fontSize: 16,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: AppColors.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
