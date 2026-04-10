import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
      const Scaffold(body: Center(child: Text('Growth Screen'))),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 24, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
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
              icon: Icons.sync_alt,
              label: 'CYCLES',
              isActive: _selectedIndex == 2,
              onTap: () => setState(() => _selectedIndex = 2),
            ),
            _NavItem(
              icon: Icons.settings,
              label: 'SETTINGS',
              isActive: _selectedIndex == 3,
              onTap: () => setState(() => _selectedIndex = 3),
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
              backgroundColor: AppColors.primary,
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

  void _showActionSheet(BuildContext context, TransactionModel transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Edit Transaction', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
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
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete Transaction', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Transaction'),
                    content: const Text('Are you sure you want to delete this transaction?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await _dbService.deleteTransaction(transaction.id!);
                  refresh();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/hand icon.png',
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'The Ledger',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Cycle Header
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x66046B5E),
                              blurRadius: 8,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CURRENT CYCLE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Oct 10 - Nov 9',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 32),
                  BalanceCard(transactions: transactions),
                  const SizedBox(height: 24),
                  SummaryBento(transactions: transactions),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 20,
                            ),
                      ),
                      TextButton(
                        onPressed: widget.onSeeAll,
                        child: Text(
                          'See All',
                          style: TextStyle(
                            color: AppColors.primary.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (transactions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'No transactions yet',
                          style: TextStyle(color: AppColors.outline),
                        ),
                      ),
                    )
                  else
                    ...transactions.map((tx) => TransactionItem(
                      transaction: tx,
                      onTap: () => _showActionSheet(context, tx),
                      onLongPress: () => _showActionSheet(context, tx),
                    )).toList(),
                  const SizedBox(height: 100), // Spacing for Bottom Nav
                ],
              ),
            ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.secondaryContainer.withOpacity(0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.onSecondaryContainer : AppColors.outline,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.onSecondaryContainer : AppColors.outline,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
