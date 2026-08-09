import 'dart:convert';
import 'dart:io';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

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
/// Appearance (theme toggle), Data management (clear done / clear all),
/// About (version / privacy), bottom notice.
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final taskController = context.watch<TaskController>();
    final categoryController = context.watch<CategoryController>();

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
              .showSnackBar(const SnackBar(content: Text('已导出数据')));
          return;
        }
        final path =
            await taskController.exportToFile(categoryController.categories);
        if (!context.mounted) return;
        final result = await Share.shareXFiles(
          [XFile(path)],
          subject: 'Todolist 备份文件',
          text: '导出待办数据',
        );
        if (!context.mounted) return;
        if (result.status == ShareResultStatus.success) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('已导出数据')));
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('导出失败：$e')));
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
          .showSnackBar(SnackBar(content: Text('已导入 $count 条任务')));
    }

    return Scaffold(
      backgroundColor: ToDoColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 44, 20, 20),
          children: [
            const Center(
              child: Text('设置',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ToDoColors.textDark)),
            ),
            const SizedBox(height: 24),
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
                  const Text('外观',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _ThemePill(
                        label: '深色模式',
                        active: themeController.mode == AppThemeMode.dark,
                        onTap: () =>
                            themeController.setMode(AppThemeMode.dark),
                      ),
                      const SizedBox(width: 12),
                      _ThemePill(
                        label: '跟随系统',
                        active: themeController.mode == AppThemeMode.system,
                        onTap: () =>
                            themeController.setMode(AppThemeMode.system),
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
                  title: '导出数据',
                  onTap: onExport,
                ),
                const Divider(height: 1, color: ToDoColors.divider),
                _Row(
                  icon: Icons.download_outlined,
                  title: '导入数据',
                  onTap: onImport,
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
                            const Text('安装为 App',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          kIsWeb
                              ? '在手机或电脑的浏览器中打开后，可通过系统菜单“添加到主屏幕”'
                                  '把它安装成独立应用，离线也能使用。\n'
                                  '· iPhone/iPad：Safari 底部“分享”→“添加到主屏幕”\n'
                                  '· Android：右上“⋮”→“安装应用”\n'
                                  '· macOS/Windows：地址栏右侧“安装”图标'
                              : '',
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
                  title: '一键清空已完成',
                  onTap: () async {
                    await taskController.clearDone();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('已清空已完成任务')));
                  },
                ),
                const Divider(height: 1, color: ToDoColors.divider),
                _Row(
                  icon: Icons.delete_outline,
                  title: '清空所有任务',
                  danger: true,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('确认清空'),
                        content: const Text('将删除全部任务，且不可恢复。'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('清空',
                                style: TextStyle(color: ToDoColors.warning)),
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
                _Row(icon: Icons.info_outline, title: '版本号 1.0.0'),
                const Divider(height: 1, color: ToDoColors.divider),
                _Row(icon: Icons.lock_outline, title: '隐私说明'),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: ToDoColors.editPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  '本地存储数据，卸载应用后无法恢复',
                  style: TextStyle(
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
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
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
