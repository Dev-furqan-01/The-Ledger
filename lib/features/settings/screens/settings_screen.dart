import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/settings_service.dart';
import '../models/currency_model.dart';
import '../constants/settings_constants.dart';
import '../widgets/settings_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isVaultSyncEnabled = true;
  bool _isDarkModeEnabled = false;
  final _settingsService = SettingsService();

  Future<void> _showCurrencyPicker() async {
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
                trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
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
                    color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primary,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            const Icon(Icons.cached, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'The Ledger',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: -1.0,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
        ],
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
                  const Text(
                    'PREFERENCES',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Account Section
                  const ProfileCard(
                    name: 'Alexander Sterling',
                    wealthId: '8829-X',
                    imageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=2574&auto=format&fit=crop',
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
                        iconContainerColor: AppColors.primaryContainer,
                        iconColor: AppColors.onPrimaryContainer,
                        trailing: Switch(
                          value: _isVaultSyncEnabled,
                          onChanged: (value) {
                            setState(() => _isVaultSyncEnabled = value);
                          },
                          activeColor: Colors.white,
                          activeTrackColor: AppColors.secondary,
                        ),
                      ),
                      const Divider(height: 1, indent: 72, endIndent: 20, color: AppColors.outlineVariant),
                      const SettingsItem(
                        icon: Icons.alternate_email,
                        title: 'Connected Account',
                        subtitle: 'a.sterling.private@gmail.com',
                        iconContainerColor: AppColors.surfaceContainerHigh,
                        iconColor: AppColors.primary,
                      ),
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
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.outlineVariant,
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
                      const SettingsItem(
                        icon: Icons.file_download_outlined,
                        title: 'Export Data',
                        subtitle: 'Download records as CSV/JSON',
                      ),
                      const Divider(height: 1, indent: 72, endIndent: 20, color: AppColors.outlineVariant),
                      const SettingsItem(
                        icon: Icons.file_upload_outlined,
                        title: 'Import Data',
                        subtitle: 'Restore ledger from a file',
                      ),
                    ],
                  ),

                  // General
                  SettingsSection(
                    title: 'General',
                    children: [
                      SettingsItem(
                        icon: Icons.dark_mode,
                        title: 'Dark Mode',
                        subtitle: 'Automatic based on system',
                        trailing: Switch(
                          value: _isDarkModeEnabled,
                          onChanged: (value) {
                            setState(() => _isDarkModeEnabled = value);
                          },
                          activeColor: Colors.white,
                          activeTrackColor: AppColors.outlineVariant,
                        ),
                      ),
                      const Divider(height: 1, indent: 72, endIndent: 20, color: AppColors.outlineVariant),
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
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.outlineVariant,
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
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(
                              color: AppColors.error.withOpacity(0.1),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Log Out of All Devices',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'THE LEDGER V${SettingsConstants.appVersion} • BUILD ${SettingsConstants.buildNumber}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: AppColors.outlineVariant,
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
