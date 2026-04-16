import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_lib;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../dashboard/models/transaction_model.dart';
import '../../splash_screen/screens/splash_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/settings_service.dart';
import '../../../local_storage/database_service.dart';
import '../models/currency_model.dart';
import '../constants/settings_constants.dart';
import '../widgets/settings_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isVaultSyncEnabled = false;
  bool _isDarkModeEnabled = false;
  final _settingsService = SettingsService();
  final _dbService = DatabaseService();

  Future<void> _exportData() async {
    try {
      final transactions = await _dbService.getTransactions();
      final data = transactions.map((tx) => tx.toMap()).toList();
      final jsonString = jsonEncode(data);

      String dirPath;
      if (Platform.isAndroid) {
        Directory dir = Directory('/storage/emulated/0/Documents/TheLedger');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        dirPath = dir.path;
      } else {
        Directory dir = await getApplicationDocumentsDirectory();
        dirPath = path_lib.join(dir.path, 'TheLedger');
        if (!await Directory(dirPath).exists()) {
          await Directory(dirPath).create(recursive: true);
        }
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'the_ledger_export_$timestamp.json';
      final file = File('$dirPath/$fileName');

      await file.writeAsString(jsonString);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved locally to: $dirPath/$fileName'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _importData() async {
    final colorScheme = Theme.of(context).colorScheme;
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final List<dynamic> jsonData = jsonDecode(jsonString);

        if (mounted) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Import Data', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold)),
              content: Text('This will import ${jsonData.length} transactions. Continue?', style: const TextStyle(fontFamily: 'Inter')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel', style: TextStyle(color: colorScheme.outline)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Import', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );

          if (confirm == true) {
            final List<TransactionModel> transactions = [];
            for (var item in jsonData) {
              if (item is Map<String, dynamic>) {
                // Ensure ID is null so it gets auto-incremented properly,
                // or keep the ID if you want to exactly mirror the old database.
                // Usually it's safer to let SQLite generate new IDs on import
                // to avoid primary key conflicts.
                final map = Map<String, dynamic>.from(item);
                map.remove('id'); 
                transactions.add(TransactionModel.fromMap(map));
              }
            }
            
            await _dbService.insertTransactions(transactions);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Data imported successfully! Reloading...'),
                  backgroundColor: colorScheme.primary,
                ),
              );
              
              // Reload app to show imported data
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const SplashScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              });
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import data: $e'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _showCurrencyPicker() async {
    final colorScheme = Theme.of(context).colorScheme;
    final Currency? picked = await showDialog<Currency>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: Currency.all.length,
            itemBuilder: (context, index) {
              final currency = Currency.all[index];
              final isSelected = currency.code == _settingsService.reportingCurrency.value.code;
              return ListTile(
                leading: Text(currency.symbol, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                title: Text(currency.name, style: const TextStyle(fontFamily: 'Inter')),
                trailing: isSelected ? Icon(Icons.check, color: colorScheme.primary) : null,
                onTap: () => Navigator.pop(context, currency),
              );
            },
          ),
        ),
      ),
    );

    if (picked != null) {
      await _settingsService.setReportingCurrency(picked);
    }
  }

  Future<void> _showAccountingStartDayPicker() async {
    final colorScheme = Theme.of(context).colorScheme;
    final int? picked = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Start Day', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 28,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isSelected = day == _settingsService.accountingStartDay.value;
              return InkWell(
                onTap: () => Navigator.pop(context, day),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    if (picked != null) {
      await _settingsService.setAccountingStartDay(picked);
    }
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
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
            Icon(Icons.cached, color: colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'The Ledger',
              style: textTheme.titleLarge?.copyWith(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                    letterSpacing: -1.0,
                  ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 768;
          final horizontalPadding = isTablet ? (constraints.maxWidth - 672) / 2 : 24.0;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Editorial Header
                  Text(
                    'PREFERENCES',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.secondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Account Section
                  const ProfileCard(
                    name: 'Guests',
                    wealthId: 'GUEST-001',
                    imageUrl: 'https://images.unsplash.com/photo-1511367461989-f85a21fda167?q=80&w=2574&auto=format&fit=crop',
                  ),
                  const SizedBox(height: 40),

                  // Security & Backup
                  SettingsSection(
                    title: 'Security & Backup',
                    children: [
                      SettingsItem(
                        icon: Icons.cloud_sync,
                        title: 'Cloud Vault Sync',
                        subtitle: 'Encrypted backup of all ledgers',
                        iconContainerColor: colorScheme.primaryContainer,
                        iconColor: colorScheme.onPrimaryContainer,
                        trailing: Switch(
                          value: _isVaultSyncEnabled,
                          onChanged: (value) {
                            if (value) {
                              showCupertinoDialog(
                                context: context,
                                builder: (context) => CupertinoAlertDialog(
                                  title: const Text('Coming Soon'),
                                  content: const Text('Cloud Vault Sync will be available in a future update.'),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('OK'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              setState(() => _isVaultSyncEnabled = value);
                            }
                          },
                          activeColor: Colors.white,
                          activeTrackColor: colorScheme.secondary,
                        ),
                      ),
                      if (_isVaultSyncEnabled) ...[
                        Divider(height: 1, indent: 72, endIndent: 20, color: colorScheme.outlineVariant),
                        SettingsItem(
                          icon: Icons.alternate_email,
                          title: 'Connected Account',
                          subtitle: 'guest@gmail.com',
                          iconContainerColor: colorScheme.surfaceContainerHigh,
                          iconColor: colorScheme.primary,
                        ),
                      ],
                    ],
                  ),

                  // Cycle Architecture
                  SettingsSection(
                    title: 'Cycle Architecture',
                    children: [
                      ValueListenableBuilder<int>(
                        valueListenable: _settingsService.accountingStartDay,
                        builder: (context, day, child) {
                          return SettingsItem(
                            icon: Icons.calendar_today,
                            title: 'Accounting Start Day',
                            subtitle: 'Currently set to the ${day}${_getDaySuffix(day)} of every month',
                            onTap: _showAccountingStartDayPicker,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Day ${day.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_right,
                                  color: colorScheme.outlineVariant,
                                  size: 20,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // Data Management
                  SettingsSection(
                    title: 'Data Management',
                    children: [
                      SettingsItem(
                        icon: Icons.file_download_outlined,
                        title: 'Export Data',
                        subtitle: 'Download records as JSON',
                        onTap: _exportData,
                      ),
                      Divider(height: 1, indent: 72, endIndent: 20, color: colorScheme.outlineVariant),
                      SettingsItem(
                        icon: Icons.file_upload_outlined,
                        title: 'Import Data',
                        subtitle: 'Restore ledger from a file',
                        onTap: _importData,
                      ),
                    ],
                  ),

                  // General
                  SettingsSection(
                    title: 'General',
                    children: [
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: _settingsService.themeMode,
                        builder: (context, mode, child) {
                          return SettingsItem(
                            icon: Icons.dark_mode,
                            title: 'Dark Mode',
                            subtitle: mode == ThemeMode.dark ? 'Enabled' : 'Disabled',
                            trailing: Switch(
                              value: mode == ThemeMode.dark,
                              onChanged: (value) {
                                _settingsService.setThemeMode(
                                  value ? ThemeMode.dark : ThemeMode.light,
                                );
                              },
                              activeColor: Colors.white,
                              activeTrackColor: colorScheme.secondary,
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, indent: 72, endIndent: 20, color: colorScheme.outlineVariant),
                      ValueListenableBuilder<Currency>(
                        valueListenable: _settingsService.reportingCurrency,
                        builder: (context, currency, child) {
                          return SettingsItem(
                            icon: Icons.payments,
                            title: 'Reporting Currency',
                            subtitle: 'Global display currency',
                            onTap: _showCurrencyPicker,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${currency.code} (${currency.symbol})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_right,
                                  color: colorScheme.outlineVariant,
                                  size: 20,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // Danger Zone
                  const SizedBox(height: 12),
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          'THE LEDGER V${SettingsConstants.appVersion} • BUILD ${SettingsConstants.buildNumber}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: colorScheme.outlineVariant,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'BUILT BY DTS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: colorScheme.outlineVariant,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 80 + MediaQuery.of(context).padding.bottom), // Adaptive spacing for Bottom Nav
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
