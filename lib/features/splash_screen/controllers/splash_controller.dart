import 'dart:async';
import 'package:flutter/material.dart';
import '../models/splash_content.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class SplashController extends ChangeNotifier {
  final BuildContext context;
  SplashContent _content = SplashContent.initial();

  SplashController(this.context);

  SplashContent get content => _content;

  void init() {
    // Simulate fetching content or checking auth
    Timer(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    });
  }
}
