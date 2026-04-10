import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/transaction_model.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDebit = transaction.type == TransactionType.debit;
    final Color accentColor = isDebit ? AppColors.error : AppColors.onTertiaryContainer;
    final String formattedDate = DateFormat('MMM d, y').format(transaction.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    transaction.icon,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$formattedDate • ${transaction.category}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isDebit ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
