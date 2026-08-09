import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/category_controller.dart';
import '../controllers/task_controller.dart';
import '../utils/colors.dart';
import 'edit_todo_page.dart';
import 'widgets/app_header.dart';
import 'widgets/category_filter.dart';
import 'widgets/todo_tile.dart';

/// Home screen (UI1 1:1 还原): header + category filter + task list + FAB.
class Home extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const Home({super.key, required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    final taskController = context.watch<TaskController>();
    final categoryController = context.watch<CategoryController>();

    final tasks = taskController.visibleTasks;

    return Scaffold(
      backgroundColor: ToDoColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              total: taskController.totalCount,
              done: taskController.doneCount,
              remaining: taskController.remainingCount,
              onSettings: onOpenSettings,
            ),
            // Search bar (V1.1 搜索任务)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: taskController.setSearch,
                  decoration: InputDecoration(
                    hintText: '搜索任务',
                    hintStyle: TextStyle(color: ToDoColors.textGrey),
                    icon: Icon(Icons.search, color: ToDoColors.textGrey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            CategoryFilter(
              categoryController: categoryController,
              selectedId: taskController.filterCategoryId,
              onSelected: taskController.setFilter,
            ),
            Expanded(
              child: tasks.isEmpty
                  ? _EmptyHint(keyword: taskController.searchKeyword)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) => TodoTile(
                        task: tasks[index],
                        onEdit: () => _openEdit(context, tasks[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEdit(context, null),
        backgroundColor: ToDoColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _openEdit(BuildContext context, dynamic task) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditTodoPage(task: task)),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String keyword;
  const _EmptyHint({this.keyword = ''});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: ToDoColors.textGrey),
          const SizedBox(height: 12),
          Text(
            keyword.isNotEmpty ? '没有匹配的任务' : '这一天还没有任务',
            style: TextStyle(color: ToDoColors.textGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
