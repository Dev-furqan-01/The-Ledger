import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
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
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
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
          // Responsive width for tablet/phone
          final isTablet = constraints.maxWidth > 700;
          final contentWidth = isTablet ? 600.0 : double.infinity;

          return SingleChildScrollView(
            child: Center(
              child: Container(
                width: contentWidth,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
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
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Account Section
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                      child: Text(
                        'ACCOUNT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                    const ProfileCard(
                      name: 'Alexander Sterling',
                      wealthId: '8829-X',
                      imageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=2574&auto=format&fit=crop',
                    ),
                    const SizedBox(height: 32),

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
                            activeColor: AppColors.secondary,
                            activeTrackColor: AppColors.secondaryContainer,
                          ),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        const SettingsItem(
                          icon: Icons.alternate_email,
                          title: 'Connected Account',
                          subtitle: 'a.sterling.private@gmail.com',
                        ),
                      ],
                    ),

                    // Cycle Architecture
                    SettingsSection(
                      title: 'Cycle Architecture',
                      children: [
                        SettingsItem(
                          icon: Icons.calendar_today,
                          title: 'Accounting Start Day',
                          subtitle: 'Currently set to the 1st of every month',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Day 01',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.outlineVariant,
                                size: 20,
                              ),
                            ],
                          ),
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
                            activeColor: AppColors.secondary,
                            activeTrackColor: AppColors.secondaryContainer,
                          ),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        const SettingsItem(
                          icon: Icons.payments,
                          title: 'Reporting Currency',
                          subtitle: 'Global display currency',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'USD (\$)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.outlineVariant,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Danger Zone
                    const SizedBox(height: 24),
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
