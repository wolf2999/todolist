import 'dart:convert';

import 'constants.dart';

/// Model: represents a single To Do task (V1.0 需求 + V1.1 优先级).
class TodoModel {
  final String id;
  final String title;
  final String note;
  final DateTime dueDate;
  final bool isDone;
  final String categoryId;
  final Priority priority;

  TodoModel({
    required this.id,
    required this.title,
    required this.dueDate,
    this.note = '',
    this.isDone = false,
    this.categoryId = kDefaultCategory,
    this.priority = Priority.medium,
  });

  TodoModel copyWith({
    String? id,
    String? title,
    String? note,
    DateTime? dueDate,
    bool? isDone,
    String? categoryId,
    Priority? priority,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
      isDone: isDone ?? this.isDone,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'note': note,
        'dueDate': dueDate.toIso8601String(),
        'isDone': isDone,
        'categoryId': categoryId,
        'priority': priority.index,
      };

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
        id: json['id'] as String,
        title: json['title'] as String,
        note: json['note'] as String? ?? '',
        dueDate: DateTime.parse(json['dueDate'] as String),
        isDone: json['isDone'] as bool? ?? false,
        categoryId: json['categoryId'] as String? ?? kDefaultCategory,
        priority: Priority.values[(json['priority'] as int? ?? 1)],
      );

  @override
  String toString() => jsonEncode(toJson());
}
