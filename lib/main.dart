import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'controllers/category_controller.dart';
import 'controllers/task_controller.dart';
import 'controllers/theme_controller.dart';
import 'utils/theme.dart';
import 'views/onboarding.dart';
import 'views/home.dart';
import 'views/category_page.dart';
import 'views/setting_page.dart';
import 'views/widgets/bottom_nav.dart';

void main() async {
  // EasyLocalization needs the binding initialized before loading assets.
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      // 支持简体中文、繁体中文、英文。首次进入跟随系统语言，用户手动切换后记住选择。
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('zh', 'TW'),
        Locale('en', 'US'),
      ],
      fallbackLocale: const Locale('zh', 'CN'),
      path: 'assets/i18n',
      useOnlyLangCode: false,
      child: const MyApp(),
    ),
  );
}

/// MVC wiring point: every Controller is provided at the top of the tree so
/// any View can read state and dispatch actions through ChangeNotifier.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskController()..load()),
        ChangeNotifierProvider(create: (_) => CategoryController()..load()),
        ChangeNotifierProvider(create: (_) => ThemeController()..load()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) => MaterialApp(
          title: 'appTitle'.tr(),
          debugShowCheckedModeBanner: false,
          // Locale is driven by EasyLocalization (follows system on first run,
          // remembers the user's choice afterwards).
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: buildTheme(),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.deepPurple,
            scaffoldBackgroundColor: const Color(0xFF15171E),
          ),
          themeMode: themeController.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const Onboarding(),
            '/main': (context) => const AppShell(),
          },
        ),
      ),
    );
  }
}

/// Hosts the bottom navigation and switches between the three main pages.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Home(onOpenSettings: () => _goTo(2)),
      const CategoryPage(),
      const SettingPage(),
    ];
  }

  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _index,
        onTap: _goTo,
      ),
    );
  }
}
