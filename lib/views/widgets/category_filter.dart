import 'package:flutter/material.dart';

import '../../controllers/category_controller.dart';
import '../../utils/colors.dart';

/// Horizontal category filter tabs (UI1: 全部 / 日常 / 工作 / 学习).
/// Includes a "全部" pseudo-tab plus every user category.
class CategoryFilter extends StatelessWidget {
  final CategoryController categoryController;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  const CategoryFilter({
    super.key,
    required this.categoryController,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _chip(context, null, '全部'),
    ];
    for (final c in categoryController.categories) {
      chips.add(_chip(context, c.id, c.name));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(children: chips),
    );
  }

  Widget _chip(BuildContext context, String? id, String name) {
    final selected = selectedId == id;
    return GestureDetector(
      onTap: () => onSelected(id),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? ToDoColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          name,
          style: TextStyle(
            color: selected ? Colors.white : ToDoColors.textGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
