import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/transaction_type_toggle.dart';
import '../widgets/category_bento_grid.dart';
import '../../dashboard/models/transaction_model.dart';
import '../../../local_storage/database_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;
  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  late DateTime _selectedDate;
  late String _selectedCategory;
  late bool _isExpense;
  bool _isSaving = false;
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.title;
      _selectedDate = widget.transaction!.date;
      _selectedCategory = widget.transaction!.category;
      _isExpense = widget.transaction!.type == TransactionType.debit;
    } else {
      _selectedDate = DateTime.now();
      _selectedCategory = 'Other';
      _isExpense = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (_isSaving) return;

    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0.0;
    final description = _descriptionController.text.trim();

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount greater than 0'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Close keyboard
      FocusScope.of(context).unfocus();

      final transaction = TransactionModel(
        id: widget.transaction?.id,
        title: description,
        date: _selectedDate,
        category: _selectedCategory,
        amount: amount,
        type: _isExpense ? TransactionType.debit : TransactionType.credit,
        icon: _getIconForCategory(_selectedCategory),
      );

      if (widget.transaction != null) {
        await _dbService.updateTransaction(transaction);
      } else {
        await _dbService.insertTransaction(transaction);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        // Wait a bit for the snackbar to be seen
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving transaction: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Shop':
        return Icons.shopping_bag;
      case 'Travel':
        return Icons.commute;
      case 'Bills':
        return Icons.receipt_long;
      case 'Health':
        return Icons.medical_services;
      case 'Salary':
        return Icons.payments;
      case 'Business':
        return Icons.work;
      case 'Other':
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.transaction != null ? 'Edit Transaction' : 'Add Transaction',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Manrope',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // Transaction Type Toggle
              TransactionTypeToggle(
                onToggle: (val) => setState(() => _isExpense = val),
              ),
              const SizedBox(height: 48),

              // Amount Input
              const Text(
                'TRANSACTION AMOUNT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.outline,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '\$',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: _isExpense ? AppColors.error : AppColors.onTertiaryContainer,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(width: 8),
                  IntrinsicWidth(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: _isExpense ? AppColors.error : AppColors.onTertiaryContainer,
                        fontFamily: 'Manrope',
                        letterSpacing: -1,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(color: AppColors.surfaceVariant),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Form Fields
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DESCRIPTION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.outline,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'What was this for?',
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Category Bento Grid
                  CategoryBentoGrid(
                    isExpense: _isExpense,
                    onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
                  ),
                  const SizedBox(height: 32),

                  // Date and Notes
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TRANSACTION DATE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.outline,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) setState(() => _selectedDate = date);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const Icon(Icons.calendar_today, color: AppColors.outline, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'NOTES (OPTIONAL)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.outline,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _notesController,
                              style: const TextStyle(fontFamily: 'Inter', fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'Add a quick note...',
                                filled: true,
                                fillColor: AppColors.surfaceContainerLow,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.all(20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 120), // Bottom nav padding
            ],
          ),
        ),
      ),
      // Sticky Action Button
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surface.withOpacity(0),
              AppColors.surface,
            ],
          ),
        ),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveTransaction,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isSaving ? AppColors.outline : AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            shadowColor: AppColors.primary.withOpacity(0.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isSaving 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save, size: 20),
              const SizedBox(width: 12),
              Text(
                _isSaving ? 'Saving...' : (widget.transaction != null ? 'Update Transaction' : 'Save Transaction'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Manrope'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
