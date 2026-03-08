// ---
// WIDGET: task_list_item.dart
// ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/logic/providers/task_provider.dart';

class TaskListItem extends StatelessWidget {
  // OOP CONCEPT: Dependency Injection via Constructor
  // This widget needs a Task to display, and a function to call when edited.
  final Task task;
  final VoidCallback onEdit;

  const TaskListItem({super.key, required this.task, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // The key must be completely unique for Dismissible to work correctly
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        // 1. Perform the deletion via Provider
        final provider = context.read<TaskProvider>();
        final originalIndex = provider.deleteTask(task);

        // 2. Clear any existing SnackBars to prevent queuing delays
        ScaffoldMessenger.of(context).clearSnackBars();

        // 3. Show the Undo SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" deleted.'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Call the provider to restore the task at its original position
                provider.undoDelete(originalIndex, task);
              },
            ),
          ),
        );
      },
      child: ListTile(
        onLongPress:
            onEdit, // Triggers the callback passed from the parent screen
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) {
            context.read<TaskProvider>().toggleTaskCompletion(task);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: task.isCompleted ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: task.description.isNotEmpty ? Text(task.description) : null,
      ),
    );
  }
}
