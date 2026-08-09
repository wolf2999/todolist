import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// View: 启动引导页
class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ToDoColors.background,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Image(
                width: MediaQuery.of(context).size.width * 0.9,
                image: const AssetImage('assets/images/home.png'),
              ),
            ),
            Positioned(
              bottom: 100,
              child: Column(
                children: [
                  Text(
                    'appTitle'.tr(),
                    style: const TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
                      color: ToDoColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'onboardDesc'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: ToDoColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 30,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: ToDoColors.primary,
                child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onPressed: () => Navigator.pushReplacementNamed(context, '/main'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}