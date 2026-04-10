import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TransactionTypeToggle extends StatefulWidget {
  final Function(bool isExpense) onToggle;
  const TransactionTypeToggle({super.key, required this.onToggle});

  @override
  State<TransactionTypeToggle> createState() => _TransactionTypeToggleState();
}

class _TransactionTypeToggleState extends State<TransactionTypeToggle> {
  bool isExpense = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleItem(
              label: 'Expense / Debit',
              isSelected: isExpense,
              activeColor: AppColors.error,
              onTap: () {
                setState(() => isExpense = true);
                widget.onToggle(true);
              },
            ),
          ),
          Expanded(
            child: _ToggleItem(
              label: 'Income / Credit',
              isSelected: !isExpense,
              activeColor: AppColors.onSecondaryContainer,
              onTap: () {
                setState(() => isExpense = false);
                widget.onToggle(false);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Manrope',
              color: isSelected ? activeColor : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
