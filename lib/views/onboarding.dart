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
                children: const [
                  Text(
                    '待办清单',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
                      color: ToDoColors.textDark,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '一个跨平台的简单方式\n让你的一天井井有条。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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