import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryBentoGrid extends StatefulWidget {
  final bool isExpense;
  final Function(String category) onCategorySelected;
  const CategoryBentoGrid({
    super.key,
    required this.onCategorySelected,
    this.isExpense = true,
  });

  @override
  State<CategoryBentoGrid> createState() => _CategoryBentoGridState();
}

class _CategoryBentoGridState extends State<CategoryBentoGrid> {
  String selectedCategory = 'Other';

  final List<Map<String, dynamic>> expenseCategories = [
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Travel', 'icon': Icons.commute},
    {'name': 'Shop', 'icon': Icons.shopping_bag},
    {'name': 'Bills', 'icon': Icons.receipt_long},
    {'name': 'Health', 'icon': Icons.medical_services},
    {'name': 'Other', 'icon': Icons.more_horiz},
  ];

  final List<Map<String, dynamic>> incomeCategories = [
    {'name': 'Salary', 'icon': Icons.payments},
    {'name': 'Business', 'icon': Icons.work},
    {'name': 'Other', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = widget.isExpense ? expenseCategories : incomeCategories;

    // Reset selected category if it's not in the current list
    if (!categories.any((c) => c['name'] == selectedCategory)) {
      selectedCategory = 'Other';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isExpense ? 'CATEGORY' : 'SOURCE',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.outline,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final bool isSelected = selectedCategory == category['name'];

            return GestureDetector(
              onTap: () {
                setState(() => selectedCategory = category['name']);
                widget.onCategorySelected(category['name']);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'],
                      color: isSelected ? Colors.white : AppColors.outline,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
