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
