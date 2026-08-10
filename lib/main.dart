import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:easy_localization/easy_localization.dart';
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
      // 关键：startLocale 控制首次启动语言。这里强制 zh-CN 简化首屏渲染时序。
      startLocale: const Locale('zh', 'CN'),
      // 翻译 JSON 加载失败时只打日志，不中断 UI —— 后续 setLocale 时会重试。
      // 用 ErrorWidget 形式给出最直观的失败提示，方便排查（如部署到 CDN 后路径
      // 写错、SW 缓存等都会走到这里）。
      errorWidget: (error) {
        debugPrint('[EasyLocalization] 加载失败: $error');
        return ErrorWidget(
          '⚠️ 翻译资源加载失败：\n${error?.toString() ?? "未知错误"}\n'
          '检查 assets/i18n/ 是否随构建产物一起部署。',
        );
      },
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
        // V1.4 优化 C: 延后数据加载。Controllers 的 load() 改为首次 build 后再异步执行，
        // 避免阻塞 runApp，让用户更快看到首屏（配合 index.html 的启动占位）。
        ChangeNotifierProvider(create: (_) => TaskController()),
        ChangeNotifierProvider(create: (_) => CategoryController()),
        ChangeNotifierProvider(create: (_) => ThemeController()..load()),
      ],
      // V1.4.4 修复：ThemeController 的读取必须放在 MultiProvider 内部的节点上，
      // 之前的写法 `context.watch<ThemeController>()` 在 runApp 返回的根 build 中执行，
      // 当时的 context 还在 Provider 树之上，导致 Provider.uninitialized 抛错、
      // Flutter 渲染进 error widget，画面卡在 splash 的 "T" logo 上不前进。
      // 现在用 MaterialApp.builder 拿到 MultiProvider 子树内的 context 来读，
      // 既能响应主题变化，又不会触发初始化顺序错误。
      child: Builder(builder: (innerContext) {
        final themeMode = innerContext.watch<ThemeController>().themeMode;
        return MaterialApp(
          title: 'appTitle'.tr(),
          debugShowCheckedModeBanner: false,
          // Locale is driven by EasyLocalization (follows system on first run,
          // remembers the user's choice afterwards).
          locale: innerContext.locale,
          supportedLocales: innerContext.supportedLocales,
          // V1.4 修复：必须使用 innerContext.localizationDelegates —— 它内部已经
          // 包含了 easy_localization 的 _EasyLocalizationDelegate，MaterialApp
          // 才会触发它的 load() 来加载翻译 JSON（RootBundleAssetLoader）。
          // 之前只放了 Global* delegates，导致 _EasyLocalizationDelegate.load
          // 永远没被调用，translations 一直为 null，所有 .tr() 回退到 key。
          localizationsDelegates: innerContext.localizationDelegates,
          theme: buildTheme(),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.deepPurple,
            scaffoldBackgroundColor: const Color(0xFF15171E),
          ),
          themeMode: themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const Onboarding(),
            '/main': (context) => const AppShell(),
          },
        );
      }),
    );
  }
}

/// Triggers lazy data loading after the first frame, and removes the static
/// HTML splash once Flutter has painted its first frame (V1.4 优化 A/C).
class _Bootstrap extends StatefulWidget {
  final Widget child;
  const _Bootstrap({required this.child});

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  @override
  void initState() {
    super.initState();
    // 首帧绘制后再加载数据，避免阻塞首屏。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TaskController>().load();
      context.read<CategoryController>().load();
      _removeHtmlSplash();
    });
  }

  /// 首帧渲染后移除 index.html 中的 #loading 占位（仅 Web 有效）。
  void _removeHtmlSplash() {
    if (!kIsWeb) return;
    // ignore: avoid_web_libraries_in_flutter
    final el = html.document.getElementById('loading');
    el?.remove();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Hosts the bottom navigation and switches between the three main pages.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _goTo(int i) => setState(() => _index = i);

  // V1.4.5 修复：每个页面加 ValueKey(locale.toString())，强制 IndexedStack 在
  // locale 变化时 dispose/recreate 所有子页面（连同它们持有的 State、tab 控制器、
  // 缓存数据），从而保证整棵底部导航及所有未激活 Tab 都用新 locale 重建。
  // 没有 Key 的话 Flutter 会复用 State，旧 Locale InheritedWidget 仍然挂在
  // 那些 State 的 context 上，导致只有当前显示页 .tr() 跟着切、其它页全是旧语言。
  List<Widget> get _pages {
    final loc = context.locale.toString();
    return [
      Home(key: ValueKey('home-$loc'), onOpenSettings: () => _goTo(2)),
      CategoryPage(key: ValueKey('cat-$loc')),
      SettingPage(key: ValueKey('set-$loc')),
    ];
  }

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
