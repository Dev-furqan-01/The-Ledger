import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../../features/settings/models/currency_model.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _keyAccountingStartDay = 'accounting_start_day';
  static const String _keyCurrencyCode = 'reporting_currency_code';
  static const String _keyThemeMode = 'theme_mode';
  late File _settingsFile;

  final ValueNotifier<int> accountingStartDay = ValueNotifier<int>(1);
  final ValueNotifier<Currency> reportingCurrency = ValueNotifier<Currency>(Currency.all[0]);
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

  Future<void> init() async {
    String path;
    if (Platform.isAndroid) {
      Directory dir = Directory('/storage/emulated/0/Documents/TheLedger');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      path = join(dir.path, 'settings.json');
    } else {
      Directory dir = await getApplicationDocumentsDirectory();
      path = join(dir.path, 'TheLedger', 'settings.json');
      if (!await Directory(join(dir.path, 'TheLedger')).exists()) {
        await Directory(join(dir.path, 'TheLedger')).create(recursive: true);
      }
    }
    _settingsFile = File(path);

    Map<String, dynamic> prefs = {};
    if (await _settingsFile.exists()) {
      try {
        final content = await _settingsFile.readAsString();
        prefs = jsonDecode(content);
      } catch (e) {
        prefs = {};
      }
    }

    accountingStartDay.value = prefs[_keyAccountingStartDay] ?? 1;
    final String currencyCode = prefs[_keyCurrencyCode] ?? 'USD';
    reportingCurrency.value = Currency.fromCode(currencyCode);
    
    final String? themeModeString = prefs[_keyThemeMode];
    if (themeModeString != null) {
      themeMode.value = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeModeString,
        orElse: () => ThemeMode.light,
      );
    }
  }

  Future<void> _savePrefs() async {
    final prefs = {
      _keyAccountingStartDay: accountingStartDay.value,
      _keyCurrencyCode: reportingCurrency.value.code,
      _keyThemeMode: themeMode.value.toString(),
    };
    await _settingsFile.writeAsString(jsonEncode(prefs));
  }

  Future<void> setAccountingStartDay(int day) async {
    if (day < 1 || day > 31) return;
    accountingStartDay.value = day;
    await _savePrefs();
  }

  Future<void> setReportingCurrency(Currency currency) async {
    reportingCurrency.value = currency;
    await _savePrefs();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _savePrefs();
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
