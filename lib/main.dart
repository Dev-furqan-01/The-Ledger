import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/settings_service.dart';
import 'features/splash_screen/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Ledger',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
