import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Priority level for a task (V1.1 需求：任务优先级 高/中/低).
enum Priority { high, medium, low }

extension PriorityInfo on Priority {
  String get label {
    switch (this) {
      case Priority.high:
        return 'priorityHigh'.tr();
      case Priority.medium:
        return 'priorityMedium'.tr();
      case Priority.low:
        return 'priorityLow'.tr();
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

  /// Maps built-in category ids to their i18n keys, so the names can be
  /// localized at display time without changing what is stored in the DB.
  static const Map<String, String> _trKeys = {
    'daily': 'catDaily',
    'work': 'catWork',
    'study': 'catStudy',
  };

  /// Returns the localized display name for a category id. For user-created
  /// categories (not in the map) the raw [name] is returned as-is.
  static String localizedName(String id, String name) =>
      _trKeys.containsKey(id) ? _trKeys[id]!.tr() : name;
}

/// Built-in theme modes (V1.0 需求 6.4).
enum AppThemeMode { light, dark, system }

/// 主页右上角「下载」入口配置 (Web / 桌面端可见，移动端隐藏).
///
/// 链接为相对路径，部署后自动指向站点根 (如 https://atodolist.pages.dev/...)。
/// 把安装包放进 `web/downloads/` 目录，随 `flutter build web` 一起发布即可。
///
/// 说明：
/// - [apkUrl]：Android 安装包 (release) 已生成，放 web/downloads/app-release.apk。
/// - [windowsExeUrl]：Windows 安装包。因 `flutter build windows` 产物是
///   一个目录 (exe + 依赖 DLL + data/)，这里直接分发 zip 包，避免引入
///   Inno Setup 等额外打包依赖。运行 `scripts/build_windows.sh` 会自动
///   生成 web/downloads/todolist-windows.zip。
class DownloadLinks {
  static const String apkUrl = 'downloads/app-release.apk';
  static const String windowsExeUrl = 'downloads/todolist-windows.zip';
  static bool get windowsReady => windowsExeUrl.isNotEmpty;
}

