import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/settings/models/currency_model.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _keyAccountingStartDay = 'accounting_start_day';
  static const String _keyCurrencyCode = 'reporting_currency_code';
  static const String _keyThemeMode = 'theme_mode';
  late SharedPreferences _prefs;

  final ValueNotifier<int> accountingStartDay = ValueNotifier<int>(1);
  final ValueNotifier<Currency> reportingCurrency = ValueNotifier<Currency>(Currency.all[0]);
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    accountingStartDay.value = _prefs.getInt(_keyAccountingStartDay) ?? 1;
    final String currencyCode = _prefs.getString(_keyCurrencyCode) ?? 'USD';
    reportingCurrency.value = Currency.fromCode(currencyCode);
    
    final String? themeModeString = _prefs.getString(_keyThemeMode);
    if (themeModeString != null) {
      themeMode.value = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setAccountingStartDay(int day) async {
    if (day < 1 || day > 31) return;
    await _prefs.setInt(_keyAccountingStartDay, day);
    accountingStartDay.value = day;
  }

  Future<void> setReportingCurrency(Currency currency) async {
    await _prefs.setString(_keyCurrencyCode, currency.code);
    reportingCurrency.value = currency;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_keyThemeMode, mode.toString());
    themeMode.value = mode;
  }

  DateTime getCurrentCycleStartDate() {
    final now = DateTime.now();
    final day = accountingStartDay.value;
    
    // If current day is >= start day, cycle started this month
    if (now.day >= day) {
      return DateTime(now.year, now.month, day);
    } else {
      // Cycle started last month
      final lastMonth = now.month == 1 ? 12 : now.month - 1;
      final year = now.month == 1 ? now.year - 1 : now.year;
      return DateTime(year, lastMonth, day);
    }
  }
}
