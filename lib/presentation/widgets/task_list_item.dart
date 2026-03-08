// ---
// WIDGET: task_list_item.dart
// ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/logic/providers/task_provider.dart';
import 'package:to_do_list_app/core/utils/color_utils.dart';
import 'package:to_do_list_app/core/constants/app_colors.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;

  const TaskListItem({super.key, required this.task, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    // Retrieve the full Category object based on the task's categoryId (Foreign Key)
    final provider = context.read<TaskProvider>();
    final taskCategory = provider.getCategoryById(task.categoryId);

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.error, // <-- Replaced Colors.red with AppColors.error
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: AppColors.surface),
      ),
      // ...
      child: ListTile(
        // ...
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            // Use semantic text colors
            color: task.isCompleted
                ? AppColors.textSecondary
                : AppColors.textPrimary,
          ),
        ),
        subtitle: task.description.isNotEmpty
            ? Text(
                task.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ), // Subtitle color
              )
            : null,
        // ---
        // VISUAL CATEGORY INDICATOR
        // ---
        // A small circular dot at the end of the row displaying the category color
        trailing: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorUtils.fromHex(taskCategory.colorHex),
            // Added a subtle border just in case the color is very light
            border: Border.all(color: Colors.black26, width: 1),
          ),
        ),
      ),
    );
  }
}
