import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/settings_service.dart';
import '../../dashboard/models/transaction_model.dart';
import '../widgets/history_transaction_item.dart';
import '../../add_transaction/screens/add_transaction_screen.dart';
import '../../../local_storage/database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTimeRange? _selectedDateRange;
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  final _settingsService = SettingsService();
  final ScrollController _scrollController = ScrollController();
  List<TransactionModel> _allTransactions = [];
  bool _isLoading = true; // For initial local read
  bool _isFetching = false; // For API sync
  bool _hasMoreData = true; // To prevent redundant API calls
  int _currentOffset = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    // Default to All Time (null)
    _selectedDateRange = null;
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isFetching && _hasMoreData) {
        _fetchOlderRecords();
      }
    }
  }

  Future<void> _loadInitialData() async {
    // Phase 1: Read instantly from local storage
    setState(() => _isLoading = true);
    final localTransactions = await _dbService.getTransactions(limit: _pageSize, offset: 0);
    setState(() {
      _allTransactions = localTransactions;
      _currentOffset = localTransactions.length;
      _isLoading = false;
    });

    // Phase 2: Optionally trigger API sync if local is empty or for freshness
    if (localTransactions.isEmpty) {
      _fetchOlderRecords();
    }
  }

  Future<void> _fetchOlderRecords() async {
    if (_isFetching || !_hasMoreData) return;

    setState(() => _isFetching = true);

    try {
      // MOCK API CALL - Replace with actual API service later
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate fetching 10 more records from an "API"
      final List<TransactionModel> newRecords = [];
      // If we were using a real API, we would fetch here and then save to DB
      // await _dbService.insertTransactions(newRecords);
      
      // For now, let's assume we reached the end if no real API is connected
      // or if the mock returns empty.
      if (newRecords.isEmpty) {
        setState(() {
          _hasMoreData = false;
          _isFetching = false;
        });
        return;
      }

      setState(() {
        _allTransactions.addAll(newRecords);
        _currentOffset += newRecords.length;
        _isFetching = false;
      });
    } catch (e) {
      setState(() => _isFetching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sync older records: $e')),
        );
      }
    }
  }

  Future<void> _loadTransactions() async {
    // Refresh full list from DB
    final transactions = await _dbService.getTransactions();
    setState(() {
      _allTransactions = transactions;
      _currentOffset = transactions.length;
    });
  }

  List<TransactionModel> get _filteredTransactions {
    return _allTransactions.where((tx) {
      if (_selectedDateRange != null) {
        final start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
        final end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59);
        if (tx.date.isBefore(start) || tx.date.isAfter(end)) {
          return false;
        }
      }
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        return tx.title.toLowerCase().contains(query) || tx.category.toLowerCase().contains(query);
      }
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Map<String, List<TransactionModel>> _groupTransactions(List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> grouped = {};
    for (var tx in transactions) {
      final String dateStr = _getDateLabel(tx.date);
      if (!grouped.containsKey(dateStr)) {
        grouped[dateStr] = [];
      }
      grouped[dateStr]!.add(tx);
    }
    return grouped;
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) {
      return 'Today — ${DateFormat('MMM d').format(date)}';
    } else if (txDate == yesterday) {
      return 'Yesterday — ${DateFormat('MMM d').format(date)}';
    } else {
      return DateFormat('EEEE — MMM d, y').format(date);
    }
  }

  Future<void> _selectDateRange() async {
    final colorScheme = Theme.of(context).colorScheme;
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: colorScheme.primary,
              primary: colorScheme.primary,
              onPrimary: colorScheme.onPrimary,
              surface: colorScheme.surface,
              onSurface: colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
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
                _loadTransactions();
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
                _loadTransactions();
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

  bool _isCurrentCycle() {
    if (_selectedDateRange == null) return false;
    final start = _settingsService.getCurrentCycleStartDate();
    final end = DateTime(start.year, start.month + 1, start.day);
    return _selectedDateRange!.start.year == start.year &&
           _selectedDateRange!.start.month == start.month &&
           _selectedDateRange!.start.day == start.day &&
           _selectedDateRange!.end.year == end.year &&
           _selectedDateRange!.end.month == end.month &&
           _selectedDateRange!.end.day == end.day;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = _filteredTransactions;
    final grouped = _groupTransactions(filtered);
    final totalTransactions = filtered.length;

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
              height: 24,
              width: 24,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
            ),
            const SizedBox(width: 8),
            Text(
              'The Ledger',
              style: textTheme.titleLarge?.copyWith(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Editorial Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'History',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A comprehensive archive of your fiscal movements. Audit your credits and debits with surgical precision.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: colorScheme.outline),
                    hintText: 'Search transactions...',
                    hintStyle: TextStyle(color: colorScheme.outline, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: _selectedDateRange == null
                          ? 'All Time'
                          : _isCurrentCycle() 
                            ? 'Current Cycle' 
                            : '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}',
                      icon: Icons.calendar_today,
                      isActive: _selectedDateRange != null,
                      onTap: _selectDateRange,
                    ),
                    if (_selectedDateRange != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          final start = _settingsService.getCurrentCycleStartDate();
                          final end = DateTime(start.year, start.month + 1, start.day);
                          setState(() => _selectedDateRange = DateTimeRange(start: start, end: end));
                        },
                        icon: Icon(Icons.refresh, size: 18, color: colorScheme.primary),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => setState(() => _selectedDateRange = null),
                        icon: Icon(Icons.close, size: 18, color: colorScheme.error),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.error.withOpacity(0.1),
                        ),
                      ),
                    ],
                    const SizedBox(width: 12),
                    Text(
                      'SHOWING $totalTransactions TRANSACTIONS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.outline,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Transaction Ledger
              if (grouped.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64),
                    child: Column(
                      children: [
                        Icon(Icons.history_toggle_off, size: 48, color: colorScheme.outline.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found for this period.',
                          style: TextStyle(color: colorScheme.outline, fontFamily: 'Inter'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...grouped.entries.expand((entry) {
                  return [
                    _DateGroupHeader(label: entry.key),
                    const SizedBox(height: 16),
                    ...entry.value.map((tx) => HistoryTransactionItem(
                          transaction: tx,
                          onTap: () => _showActionSheet(context, tx),
                          onLongPress: () => _showActionSheet(context, tx),
                        )),
                    const SizedBox(height: 32),
                  ];
                }),

              // Loader Indicator
              if (_isFetching && _hasMoreData)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Opacity(
                          opacity: 0.4,
                          child: Text(
                            'RETRIEVING OLDER RECORDS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 80 + MediaQuery.of(context).padding.bottom), // Adaptive spacing for Bottom Nav
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateGroupHeader extends StatelessWidget {
  final String label;
  const _DateGroupHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: colorScheme.outline,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}
