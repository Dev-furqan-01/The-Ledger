import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/settings_service.dart';
import '../models/transaction_model.dart';
import '../widgets/balance_card.dart';
import '../widgets/summary_bento.dart';
import '../widgets/transaction_item.dart';
import '../../history/screens/history_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../add_transaction/screens/add_transaction_screen.dart';
import '../../../local_storage/database_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<_HomeViewState> _homeKey = GlobalKey<_HomeViewState>();
  final _settingsService = SettingsService();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _HomeView(
        key: _homeKey,
        onSeeAll: () => setState(() => _selectedIndex = 1),
      ),
      const HistoryScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom > 0 
              ? MediaQuery.of(context).padding.bottom 
              : 12, // Minimal padding for devices without system nav bar
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.account_balance_wallet,
              label: 'VAULT',
              isActive: _selectedIndex == 0,
              onTap: () => setState(() => _selectedIndex = 0),
            ),
            _NavItem(
              icon: Icons.receipt_long,
              label: 'HISTORY',
              isActive: _selectedIndex == 1,
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            _NavItem(
              icon: Icons.settings,
              label: 'SETTINGS',
              isActive: _selectedIndex == 2,
              onTap: () => setState(() => _selectedIndex = 2),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
                );
                if (result == true) {
                  _homeKey.currentState?.refresh();
                }
              },
              backgroundColor: colorScheme.primary,
              shape: const CircleBorder(),
              elevation: 8,
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            )
          : null,
    );
  }
}

class _HomeView extends StatefulWidget {
  final VoidCallback? onSeeAll;
  const _HomeView({super.key, this.onSeeAll});

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final DatabaseService _dbService = DatabaseService();
  final _settingsService = SettingsService();
  late Future<List<TransactionModel>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _dbService.getTransactions();
  }

  void refresh() {
    setState(() {
      _transactionsFuture = _dbService.getTransactions();
    });
  }

  List<TransactionModel> _filterTransactionsForCurrentCycle(List<TransactionModel> transactions) {
    final cycleStart = _settingsService.getCurrentCycleStartDate();
    final nextCycleStart = DateTime(cycleStart.year, cycleStart.month + 1, cycleStart.day);
    return transactions.where((tx) {
      final date = tx.date;
      return (date.isAfter(cycleStart) || date.isAtSameMomentAs(cycleStart)) && 
             date.isBefore(nextCycleStart);
    }).toList();
  }

  String _getCycleDateRangeText() {
    final start = _settingsService.getCurrentCycleStartDate();
    // End date is exactly one month minus one day after start, 
    // but users often prefer seeing "11 Apr - 11 May" if they meant a full month.
    // The user said "show 11 apr to 11 may etc...". 
    // This usually implies the cycle ends the day before the next cycle starts.
    // But to match "11 apr to 11 may", we'll just add exactly one month.
    final end = DateTime(start.year, start.month + 1, start.day);
    final format = DateFormat('MMM d');
    return '${format.format(start)} - ${format.format(end)}';
  }

  void _showActionSheet(BuildContext context, TransactionModel transaction) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Manage Transaction'),
        message: Text(
          '${transaction.title} - ${NumberFormat.currency(symbol: '', decimalDigits: 2).format(transaction.amount)}',
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTransactionScreen(transaction: transaction),
                ),
              );
              if (result == true) {
                refresh();
              }
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.pencil),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              final confirmed = await showCupertinoDialog<bool>(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Delete Transaction'),
                  content: const Text('Are you sure you want to delete this transaction?'),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await _dbService.deleteTransaction(transaction.id!);
                refresh();
              }
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.delete),
                SizedBox(width: 8),
                Text('Delete'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/hand icon.png',
              width: 32,
              height: 32,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
            ),
            const SizedBox(width: 8),
            Text(
              'Zepensia',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allTransactions = snapshot.data ?? [];

          return ValueListenableBuilder<int>(
            valueListenable: _settingsService.accountingStartDay,
            builder: (context, day, child) {
              final cycleTransactions = _filterTransactionsForCurrentCycle(allTransactions);
              
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Cycle Header
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.secondary.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'CURRENT CYCLE',
                            style: textTheme.labelSmall?.copyWith(
                                  letterSpacing: 1.1,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCycleDateRangeText(),
                        style: textTheme.headlineSmall?.copyWith(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 32),
                      BalanceCard(transactions: cycleTransactions),
                      const SizedBox(height: 24),
                      SummaryBento(transactions: cycleTransactions),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: textTheme.titleLarge?.copyWith(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  fontSize: 20,
                                ),
                          ),
                          TextButton(
                            onPressed: widget.onSeeAll,
                            child: Text(
                              'See All',
                              style: TextStyle(
                                color: colorScheme.primary.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (cycleTransactions.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              'No transactions in this cycle',
                              style: TextStyle(color: colorScheme.outline),
                            ),
                          ),
                        )
                      else
                        ...cycleTransactions.map((tx) => TransactionItem(
                          transaction: tx,
                          onTap: () => _showActionSheet(context, tx),
                          onLongPress: () => _showActionSheet(context, tx),
                        )).toList(),
                      SizedBox(height: 80 + MediaQuery.of(context).padding.bottom), // Adaptive spacing for Bottom Nav
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.secondaryContainer.withOpacity(0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? colorScheme.onSecondaryContainer : colorScheme.outline,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? colorScheme.onSecondaryContainer : colorScheme.outline,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
