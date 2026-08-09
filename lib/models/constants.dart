import 'package:flutter/material.dart';

/// Priority level for a task (V1.1 需求：任务优先级 高/中/低).
enum Priority { high, medium, low }

extension PriorityInfo on Priority {
  String get label {
    switch (this) {
      case Priority.high:
        return '高';
      case Priority.medium:
        return '中';
      case Priority.low:
        return '低';
    }
  }

  Color get color {
    switch (this) {
      case Priority.high:
        return const Color(0xFFF25F5C);
      case Priority.medium:
        return const Color(0xFFF5A623);
      case Priority.low:
        return const Color(0xFF4CAF85);
    }
  }
}

/// Default category ids. New tasks default to 日常.
const String kDefaultCategory = 'daily';

/// Built-in categories seeded on first launch (V1.0 需求 6.1 / 6.5).
class BuiltInCategories {
  static const List<Map<String, String>> list = [
    {'id': 'daily', 'name': '日常'},
    {'id': 'work', 'name': '工作'},
    {'id': 'study', 'name': '学习'},
  ];
}

/// Built-in theme modes (V1.0 需求 6.4).
enum AppThemeMode { light, dark, system }

/// 主页右上角「下载」入口配置 (Web / 桌面端可见，移动端隐藏).
///
/// 链接为相对路径，部署后自动指向站点根 (如 https://todolist.pages.dev/...)。
/// 把安装包放进 `web/downloads/` 目录，随 `flutter build web` 一起发布即可。
///
/// 说明：
/// - [apkUrl]：Android 安装包 (release) 已生成，放 web/downloads/app-release.apk。
/// - [windowsExeUrl]：Windows 安装包需切到 Windows 机器 `flutter build windows`
///   后把 exe (及依赖) 打包上传，再把此处替换成真实相对路径即可；留空表示未就绪。
class DownloadLinks {
  static const String apkUrl = 'downloads/app-release.apk';
  static const String windowsExeUrl = ''; // TODO: 切到 Windows 打包后填 'downloads/todolist-setup.exe'
  static bool get windowsReady => windowsExeUrl.isNotEmpty;
}

