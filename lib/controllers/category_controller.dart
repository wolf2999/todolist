import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category_model.dart';
import '../models/constants.dart';

/// Controller: owns the category list (MVC controller layer).
/// V1.0 需求 6.1 分类管理：新增 / 删除 / 重命名。
class CategoryController extends ChangeNotifier {
  static const String _storageKey = 'todolist.categories.v1';

  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => List.unmodifiable(_categories);

  CategoryModel? byId(String id) =>
      _categories.where((c) => c.id == id).isEmpty
          ? null
          : _categories.firstWhere((c) => c.id == id);

  String nameOf(String id) => byId(id)?.name ?? '未分类';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey);
    if (raw == null) {
      // Seed built-in categories on first launch.
      _categories = BuiltInCategories.list
          .map((m) => CategoryModel(id: m['id']!, name: m['name']!))
          .toList();
      await _persist();
      notifyListeners();
      return;
    }
    _categories = raw.map((s) => CategoryModel.fromJson(_decode(s))).toList();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _categories.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }

  Future<void> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final id = 'cat_${DateTime.now().millisecondsSinceEpoch}';
    _categories.add(CategoryModel(id: id, name: trimmed));
    notifyListeners();
    await _persist();
  }

  Future<void> removeCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
    await _persist();
  }

  /// Replace the whole category list (V1.2 全量导入).
  Future<void> replaceAll(List<CategoryModel> categories) async {
    _categories = List.from(categories);
    notifyListeners();
    await _persist();
  }

  Map<String, dynamic> _decode(String s) =>
      Map<String, dynamic>.from(jsonDecode(s) as Map);
}
