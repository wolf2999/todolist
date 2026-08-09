import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/category_controller.dart';
import '../controllers/task_controller.dart';
import '../models/constants.dart';
import '../models/todo_model.dart';
import '../utils/colors.dart';
import '../utils/date_helper.dart';

/// Add / edit task page (UI2 1:1 还原).
/// Purple gradient header, form card, save / cancel buttons.
class EditTodoPage extends StatefulWidget {
  final TodoModel? task;

  const EditTodoPage({super.key, this.task});

  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _dueDate;
  late String _categoryId;
  late Priority _priority;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleController.text = t?.title ?? '';
    _noteController.text = t?.note ?? '';
    _dueDate = t?.dueDate ?? DateTime.now();
    _categoryId = t?.categoryId ??
        context.read<CategoryController>().categories.first.id;
    _priority = t?.priority ?? Priority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: context.locale,
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );
    if (!mounted) return;
    setState(() {
      _dueDate = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _dueDate.hour,
        time?.minute ?? _dueDate.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('titleRequired'.tr())),
      );
      return;
    }
    final taskController = context.read<TaskController>();
    if (_isEditing) {
      final updated = widget.task!.copyWith(
        title: _titleController.text.trim(),
        note: _noteController.text.trim(),
        dueDate: _dueDate,
        categoryId: _categoryId,
        priority: _priority,
      );
      await taskController.updateTask(updated);
    } else {
      final newTask = TodoModel(
        id: 'todo_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        note: _noteController.text.trim(),
        dueDate: _dueDate,
        categoryId: _categoryId,
        priority: _priority,
      );
      await taskController.addTask(newTask);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoryController = context.watch<CategoryController>();
    return Scaffold(
      backgroundColor: ToDoColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onCancel: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('title'.tr()),
                      _Input(
                        controller: _titleController,
                        hint: 'titleHint'.tr(),
                      ),
                      const SizedBox(height: 18),
                      _FieldLabel('description'.tr()),
                      _Input(
                        controller: _noteController,
                        hint: 'descriptionHint'.tr(),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 18),
                      _FieldLabel('dueDate'.tr()),
                      GestureDetector(
                        onTap: _pickDateTime,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: ToDoColors.grey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time,
                                  color: ToDoColors.textGrey, size: 18),
                              const SizedBox(width: 10),
                              Text(
                                '${DateHelper.formatFull(_dueDate)} ${DateHelper.formatTime(_dueDate)}',
                                style: TextStyle(color: ToDoColors.textDark),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _FieldLabel('priority'.tr()),
                      _PrioritySelector(
                        value: _priority,
                        onChanged: (p) => setState(() => _priority = p),
                      ),
                      const SizedBox(height: 18),
                      _FieldLabel('category'.tr()),
                      Wrap(
                        spacing: 10,
                        children: categoryController.categories
                            .map((c) => _CategoryChoice(
                                  name: BuiltInCategories.localizedName(c.id, c.name),
                                  selected: _categoryId == c.id,
                                  onTap: () =>
                                      setState(() => _categoryId = c.id),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _Actions(
              onSave: _save,
              onCancel: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onCancel;
  const _Header({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ToDoColors.editPrimary, ToDoColors.editPrimaryDark],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onCancel,
              child: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 22),
            ),
          ),
          Text(
            'editTodo'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ToDoColors.textDark,
          ),
        ),
      );
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _Input({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: ToDoColors.textGrey),
          filled: true,
          fillColor: ToDoColors.grey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      );
}

class _PrioritySelector extends StatelessWidget {
  final Priority value;
  final ValueChanged<Priority> onChanged;
  const _PrioritySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(
        children: Priority.values
            .map((p) => Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(p),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: value == p
                            ? p.color.withValues(alpha: 0.16)
                            : ToDoColors.grey,
                        borderRadius: BorderRadius.circular(12),
                        border: value == p
                            ? Border.all(color: p.color)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          p.label,
                          style: TextStyle(
                            color: value == p ? p.color : ToDoColors.textGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      );
}

class _CategoryChoice extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChoice({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? ToDoColors.editPrimary : ToDoColors.grey,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            name,
            style: TextStyle(
              color: selected ? Colors.white : ToDoColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
}

class _Actions extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;
  const _Actions({required this.onSave, required this.onCancel});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ToDoColors.editPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text('save'.tr(),
                    style:
                        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ToDoColors.editPrimary.withValues(alpha: 0.14),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text('cancel'.tr(),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ToDoColors.editPrimary)),
              ),
            ),
          ],
        ),
      );
}
