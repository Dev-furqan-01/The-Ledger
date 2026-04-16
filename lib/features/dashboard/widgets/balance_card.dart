import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/settings_service.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';

class BalanceCard extends StatelessWidget {
  final List<TransactionModel> transactions;

  const BalanceCard({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final settingsService = SettingsService();
    final colorScheme = Theme.of(context).colorScheme;
    double totalCredit = 0;
    double totalDebit = 0;

    for (var tx in transactions) {
      if (tx.type == TransactionType.credit) {
        totalCredit += tx.amount;
      } else {
        totalDebit += tx.amount;
      }
    }

    final balance = totalCredit - totalDebit;
    final currencyFormat = NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'REMAINING BALANCE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimary.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder(
                valueListenable: settingsService.reportingCurrency,
                builder: (context, currency, child) {
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          currency.symbol,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: colorScheme.onPrimary.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currencyFormat.format(balance),
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: colorScheme.onPrimary,
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // User Avatars
                  SizedBox(
                    width: 80,
                    height: 40,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: colorScheme.primary,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: colorScheme.surface,
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/hand icon.png',
                                  fit: BoxFit.cover,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 24,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: colorScheme.primary,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: colorScheme.surfaceVariant,
                              backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=2'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
