import 'dart:convert';
import 'dart:io';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/category_controller.dart';
import '../controllers/task_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/constants.dart';
import '../utils/colors.dart';

/// Settings screen (UI4 1:1 还原).
/// Language switcher, Appearance (theme toggle), Data management (import/export,
/// clear done / clear all), About (version / privacy), bottom notice.
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  static const List<Locale> _languages = [
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
    Locale('en', 'US'),
  ];

  static const List<String> _languageLabels = [
    '简体中文',
    '繁體中文',
    'English',
  ];

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final taskController = context.watch<TaskController>();
    final categoryController = context.watch<CategoryController>();
    final currentLocale = context.locale;

    Future<void> onExport() async {
      try {
        if (kIsWeb) {
          final bytes = taskController.exportBytes(categoryController.categories);
          final fileName = taskController.exportFileName();
          final blob = html.Blob(<Object>[bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..download = fileName;
          anchor.click();
          html.Url.revokeObjectUrl(url);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('exported'.tr())));
          return;
        }
        final path =
            await taskController.exportToFile(categoryController.categories);
        if (!context.mounted) return;
        final result = await Share.shareXFiles(
          [XFile(path)],
          subject: 'Todolist'.tr(),
          text: 'exportData'.tr(),
        );
        if (!context.mounted) return;
        if (result.status == ShareResultStatus.success) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('exported'.tr())));
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('exportFailed'.tr(namedArgs: {'msg': '$e'}))));
      }
    }

    Future<void> onImport() async {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: kIsWeb,
      );
      if (picked == null || picked.files.isEmpty) return;
      final f = picked.files.single;
      String content;
      if (kIsWeb) {
        if (f.bytes == null) return;
        content = utf8.decode(f.bytes!);
      } else {
        if (f.path == null) return;
        final file = File(f.path!);
        if (!await file.exists()) return;
        content = await file.readAsString();
      }
      final count = await taskController.importAll(content,
          onCategories: (cats) => categoryController.replaceAll(cats));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('imported'.tr(namedArgs: {'count': count.toString()}))));
    }

    return Scaffold(
      backgroundColor: ToDoColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 44, 20, 20),
          children: [
            Center(
              child: Text('setting'.tr(),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ToDoColors.textDark)),
            ),
            const SizedBox(height: 24),
            // Language switcher (V1.4)
            _SectionCard(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Text('language'.tr(),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ToDoColors.textGrey)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
                  // V1.4.1 修复：原本的 for + spread + 多个 Expanded 在 Flutter web
                  // 上行为不可靠 (chromium 2026/150 上偶发只渲染 1 个 chip)。
                  // 改为静态列出 3 个 Expanded 子元素，绕开 spread element 的边角问题。
                  child: Row(
                    children: [
                      Expanded(
                        child: _LanguagePill(
                          label: _languageLabels[0],
                          active: currentLocale.languageCode == 'zh' &&
                              currentLocale.countryCode == 'CN',
                          onTap: () => context.setLocale(_languages[0]),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LanguagePill(
                          label: _languageLabels[1],
                          active: currentLocale.languageCode == 'zh' &&
                              currentLocale.countryCode == 'TW',
                          onTap: () => context.setLocale(_languages[1]),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LanguagePill(
                          label: _languageLabels[2],
                          active: currentLocale.languageCode == 'en',
                          onTap: () => context.setLocale(_languages[2]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Appearance
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ToDoColors.editPrimary, ToDoColors.editPrimaryDark],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('theme'.tr(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _ThemePill(
                          label: 'darkMode'.tr(),
                          active: themeController.mode == AppThemeMode.dark,
                          onTap: () =>
                              themeController.setMode(AppThemeMode.dark),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ThemePill(
                          label: 'followSystem'.tr(),
                          active: themeController.mode == AppThemeMode.system,
                          onTap: () =>
                              themeController.setMode(AppThemeMode.system),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 数据导入 / 导出 (V1.2)
            _SectionCard(
              children: [
                _Row(
                  icon: Icons.upload_outlined,
                  title: 'exportData'.tr(),
                  onTap: onExport,
                ),
                const Divider(height: 1, color: ToDoColors.divider),
                _Row(
                  icon: Icons.download_outlined,
                  title: 'importData'.tr(),
                  onTap: onImport,
                ),
                const Divider(height: 1, color: ToDoColors.divider),
                _Row(
                  icon: Icons.forum_outlined,
                  title: 'messageBoard'.tr(),
                  // 留言板以独立 HTML 页面部署，新窗口打开 (CF Pages 静态托管)。
                  // 在 Web 上调用 window.open；非 Web 直接占位提示，避免误触。
                  onTap: () {
                    if (kIsWeb) {
                      // ignore: avoid_web_libraries_in_flutter
                      html.window.open('/message_board.html', '_blank');
                    }
                  },
                ),
                _Row(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'messageBoardAdmin'.tr(),
                  // 管理页需要管理员密钥；密钥不写入客户端（避免被反编译泄露），
                  // 打开后手动粘贴密钥即可。便捷 URL（带 ?key=）可自行收藏本机使用。
                  onTap: () {
                    if (kIsWeb) {
                      // ignore: avoid_web_libraries_in_flutter
                      html.window.open('/message_board_admin.html', '_blank');
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // PWA 安装引导 (Web 平台可见)
            if (kIsWeb)
              _SectionCard(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.add_to_home_screen_outlined,
                                color: ToDoColors.primary, size: 22),
                            const SizedBox(width: 10),
                            Text('installApp'.tr(),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'installAppHint'.tr(),
                          style: TextStyle(
                              fontSize: 13, color: ToDoColors.textGrey, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            // Data management
            _SectionCard(
              children: [
                _Row(
                  icon: Icons.check_circle_outline,
                  title: 'clearDone'.tr(),
                  onTap: () async {
                    await taskController.clearDone();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('clearDone'.tr())));
                  },
                ),
                const Divider(height: 1, color: ToDoColors.divider),
                _Row(
                  icon: Icons.delete_outline,
                  title: 'clearAll'.tr(),
                  danger: true,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('confirmClear'.tr()),
                        content: Text('deleteAllWarn'.tr()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text('cancel'.tr()),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text('clear'.tr(),
                                style: const TextStyle(color: ToDoColors.warning)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await taskController.clearAll();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // About
            _SectionCard(
              children: [
                _Row(icon: Icons.info_outline, title: 'version'.tr()),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: ToDoColors.editPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'localData'.tr(),
                  style: const TextStyle(
                      color: ToDoColors.editPrimary, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemePill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ThemePill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          decoration: BoxDecoration(
            color: active
                ? Colors.white
                : Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? ToDoColors.editPrimary : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
}

/// 白色卡片背景下的语言 chip — 配色与 _ThemePill 相反（白底灰边、active 用主题色填充）。
class _LanguagePill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _LanguagePill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: active ? ToDoColors.editPrimary : Colors.transparent,
            border: Border.all(
              color: active ? ToDoColors.editPrimary : ToDoColors.divider,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : ToDoColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ),
      );
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(children: children),
      );
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool danger;
  final VoidCallback? onTap;
  const _Row({
    required this.icon,
    required this.title,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        leading: Icon(icon,
            color: danger ? ToDoColors.warning : ToDoColors.textGrey),
        title: Text(
          title,
          style: TextStyle(
            color: danger ? ToDoColors.warning : ToDoColors.textDark,
            fontSize: 15,
          ),
        ),
        trailing:
            onTap != null ? const Icon(Icons.chevron_right, color: ToDoColors.textGrey) : null,
      );
}
