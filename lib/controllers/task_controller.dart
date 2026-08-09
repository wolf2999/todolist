import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category_model.dart';
import '../models/todo_model.dart';

/// Controller: owns the task list, exposes mutations, filtering, search,
/// backup & restore, and persists to disk (MVC controller layer).
class TaskController extends ChangeNotifier {
  static const String _storageKey = 'todolist.tasks.v2';

  List<TodoModel> _tasks = [];
  bool _isLoaded = false;

  /// Current category filter; null means "全部".
  String? _filterCategoryId;
  /// Current search keyword (V1.1).
  String _searchKeyword = '';

  List<TodoModel> get tasks => List.unmodifiable(_tasks);
  bool get isLoaded => _isLoaded;
  String? get filterCategoryId => _filterCategoryId;
  String get searchKeyword => _searchKeyword;

  int get totalCount => _tasks.length;
  int get doneCount => _tasks.where((t) => t.isDone).length;
  int get remainingCount => _tasks.length - doneCount;

  /// Tasks filtered by category + search keyword, sorted by due date.
  List<TodoModel> get visibleTasks {
    var list = List<TodoModel>.from(_tasks);
    if (_filterCategoryId != null) {
      list = list.where((t) => t.categoryId == _filterCategoryId).toList();
    }
    if (_searchKeyword.trim().isNotEmpty) {
      final kw = _searchKeyword.trim().toLowerCase();
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(kw) ||
              t.note.toLowerCase().contains(kw))
          .toList();
    }
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  List<TodoModel> tasksForCategory(String categoryId) =>
      _tasks.where((t) => t.categoryId == categoryId).toList();

  /// Load persisted tasks. Safe to call multiple times.
  Future<void> load() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    _tasks = raw.map((s) => TodoModel.fromJson(_decode(s))).toList();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _tasks.map((t) => jsonEncode(t.toJson())).toList(),
    );
  }

  void setFilter(String? categoryId) {
    _filterCategoryId = categoryId;
    notifyListeners();
  }

  void setSearch(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  Future<void> addTask(TodoModel task) async {
    _tasks.add(task);
    notifyListeners();
    await _persist();
  }

  Future<void> toggleDone(TodoModel task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(isDone: !_tasks[index].isDone);
    notifyListeners();
    await _persist();
  }

  Future<void> removeTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> updateTask(TodoModel updated) async {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index == -1) return;
    _tasks[index] = updated;
    notifyListeners();
    await _persist();
  }

  /// Count of done tasks in a category (for clear-completed action).
  Future<void> clearDone() async {
    _tasks.removeWhere((t) => t.isDone);
    notifyListeners();
    await _persist();
  }

  /// Remove every task (V1.0 需求 6.4 数据管理 / 清空所有任务).
  Future<void> clearAll() async {
    _tasks.clear();
    notifyListeners();
    await _persist();
  }

  // ---- V1.1 数据备份与恢复 ----

  /// Export all tasks as a JSON file and return its path.
  Future<String> backup() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'todolist_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${dir.path}/$fileName');
    final payload = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': _tasks.map((t) => t.toJson()).toList(),
    };
    await file.writeAsString(jsonEncode(payload));
    return file.path;
  }

  /// Replace current tasks with tasks read from a backup file (V1.1 恢复).
  Future<int> restore(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return 0;
    final content = await file.readAsString();
    final payload = _decode(content);
    final list = (payload['tasks'] as List)
        .map((e) => TodoModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    _tasks = list;
    notifyListeners();
    await _persist();
    return _tasks.length;
  }

  // ---- V1.2 全量导入 / 导出（任务 + 分类，跨平台可用）----

  /// Build the full export payload (tasks + categories) as a JSON string.
  /// [categories] comes from [CategoryController.categories].
  String buildExportPayload(List<CategoryModel> categories) {
    final payload = {
      'app': 'todolist',
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': _tasks.map((t) => t.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
    };
    return jsonEncode(payload);
  }

  /// Write the full payload (tasks + categories) to a JSON file and return its path.
  /// Native only: requires [path_provider] which is not implemented on Web.
  Future<String> exportToFile(List<CategoryModel> categories) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = exportFileName();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(buildExportPayload(categories));
    return file.path;
  }

  /// Build payload + filename. Web uses [exportBytes] for download,
  /// native uses [exportToFile] then share.
  Uint8List exportBytes(List<CategoryModel> categories) =>
      Uint8List.fromList(utf8.encode(buildExportPayload(categories)));

  String exportFileName() =>
      'todolist_export_${DateTime.now().millisecondsSinceEpoch}.json';

  /// Replace current tasks AND categories from a backup file content.
  /// Returns the number of imported tasks.
  /// [onCategories] is invoked with imported categories (caller persists them).
  Future<int> importAll(String content,
      {required void Function(List<CategoryModel>) onCategories}) async {
    final payload = _decode(content);
    final tasks = (payload['tasks'] as List? ?? [])
        .map((e) => TodoModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final categories = (payload['categories'] as List? ?? [])
        .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    _tasks = tasks;
    onCategories(categories);
    notifyListeners();
    await _persist();
    return _tasks.length;
  }

  Map<String, dynamic> _decode(String s) =>
      Map<String, dynamic>.from(jsonDecode(s) as Map);
}
