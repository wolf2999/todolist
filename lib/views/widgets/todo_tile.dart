import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/category_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/todo_model.dart';
import '../../utils/colors.dart';
import '../../utils/date_helper.dart';
import 'priority_chip.dart';

/// A single task card (UI1 1:1 还原).
/// Left: round check button. Middle: title + time + priority. Right: edit & delete.
class TodoTile extends StatelessWidget {
  final TodoModel task;
  final VoidCallback onEdit;

  const TodoTile({super.key, required this.task, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final categoryController = context.read<CategoryController>();
    final taskController = context.read<TaskController>();

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: ToDoColors.warning,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      onDismissed: (_) => taskController.removeTask(task.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Round check button
            GestureDetector(
              onTap: () => taskController.toggleDone(task),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isDone
                        ? ToDoColors.primary
                        : ToDoColors.textGrey.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  color: task.isDone ? ToDoColors.primary : Colors.transparent,
                ),
                child: task.isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            // Title + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: task.isDone
                          ? ToDoColors.textGrey
                          : ToDoColors.textDark,
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 13,
                        color: ToDoColors.textGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${DateHelper.relative(task.dueDate)} ${DateHelper.formatTime(task.dueDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: ToDoColors.textGrey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PriorityChip(priority: task.priority),
                      const SizedBox(width: 6),
                      Text(
                        categoryController.nameOf(task.categoryId),
                        style: TextStyle(
                          fontSize: 12,
                          color: ToDoColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Edit + delete actions
            IconButton(
              onPressed: onEdit,
              icon: Icon(
                Icons.edit_outlined,
                size: 20,
                color: ToDoColors.primary,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => taskController.removeTask(task.id),
              icon: Icon(
                Icons.close,
                size: 20,
                color: ToDoColors.textGrey,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
