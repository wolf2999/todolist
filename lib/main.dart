import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'services/splash.dart';

import 'controllers/category_controller.dart';
import 'controllers/task_controller.dart';
import 'controllers/theme_controller.dart';
import 'utils/theme.dart';
import 'views/onboarding.dart';
import 'views/home.dart';
import 'views/category_page.dart';
import 'views/setting_page.dart';
import 'views/widgets/bottom_nav.dart';

/// V1.4.6 修复：手机浏览器白屏。
/// 根因：之前 splash(#loading)的移除完全依赖 index.html 的 MutationObserver，
/// 而它只在 Flutter 引擎注入 <flt-glass-pane> 时立即触发——此时首帧尚未绘制
/// （HTML 渲染器下框架会等 Rubik 字体从网络下载完才绘制首帧）。手机网络慢时
/// 字体加载耗时较长，splash 被提前移除后用户看到的是空 flt-glass-pane = 白屏；
/// 桌面网络快、字体秒加载，所以看不出问题。
/// 修复：(1) 用 FontLoader 异步加载 Rubik，首帧先以系统字体绘制、字体到位后自动
/// 重绘，字体加载不再阻塞首帧；(2) 把 _Bootstrap 接入组件树，由 Dart 端在首帧
/// postFrameCallback 后才移除 splash，彻底盖住加载等待期。
Future<void> _loadFontsSafely() async {
  if (!kIsWeb) return;
  try {
    final loader = FontLoader('Rubik')
      ..addFont(rootBundle.load('assets/fonts/Rubik/Rubik-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Rubik/Rubik-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Rubik/Rubik-Bold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Rubik/Rubik-Black.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Rubik/Rubik-Light.ttf'));
    await loader.load().timeout(const Duration(seconds: 8));
  } catch (e) {
    // 字体加载失败也不阻塞首屏，使用系统字体回退即可。
    debugPrint('[FontLoader] Rubik 加载失败，回退系统字体: $e');
  }
}

void main() async {
  // EasyLocalization needs the binding initialized before loading assets.
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // V1.4.6：运行时异步加载 Rubik 字体（带超时）。必须在 runApp 前完成注册，
  // 这样首帧绘制时框架认为 'Rubik' 已可用、不会阻塞等待网络字体下载，
  // 手机慢网环境下避免 “splash 消失后白屏”。失败则回退系统字体。
  await _loadFontsSafely();
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
      // V1.4.6 修复：再包一层 _Bootstrap，由 Dart 端在首帧 postFrameCallback 之后
      // 才移除 index.html 的 #loading splash，盖住字体/资源加载等待期，
      // 彻底消除手机端 “splash 消失即白屏”（此前 splash 移除时机过早）。
      child: _Bootstrap(
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
      ),
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

  /// 首帧渲染后移除 index.html 中的 #loading 占位（仅 Web 有效，原生平台为空操作）。
  void _removeHtmlSplash() {
    removeHtmlSplash();
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
