import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../widgets/splash_icon_frame.dart';
import '../widgets/splash_identity.dart';
import '../widgets/splash_footer.dart';

import '../controllers/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SplashController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SplashController(context);
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.splashGradient,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative background circles
            Positioned(
              top: -MediaQuery.of(context).size.height * 0.1,
              left: -MediaQuery.of(context).size.width * 0.05,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: const ColorFilter.mode(Colors.white, BlendMode.dstIn),
                  child: Container(),
                ),
              ),
            ),
            Positioned(
              bottom: -MediaQuery.of(context).size.height * 0.05,
              right: -MediaQuery.of(context).size.width * 0.1,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.03),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Surface layering details (Visual Interest)
            Center(
              child: Container(
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 850,
                height: 850,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.03),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Central content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SplashIconFrame(),
                  const SizedBox(height: 32),
                  SplashIdentity(content: _controller.content),
                ],
              ),
            ),
            // Footer
            Positioned(
              bottom: 64,
              child: SplashFooter(content: _controller.content),
            ),
          ],
        ),
      ),
    );
  }
}
