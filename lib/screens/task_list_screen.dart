import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// IMPORTANT: Make sure these import paths match your actual project structure!
import '../models/task.dart';
// import '../data/mock_data.dart'; // Only needed if you want to load mock data initially

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // We start with an empty list. It will be populated from the device's storage.
  List<Task> tasks = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // ---
  // LIFECYCLE: initState
  // ---
  @override
  void initState() {
    super.initState();
    _loadTasksFromDevice();
  }

  // ---
  // DATA PERSISTENCE: LOAD (READ)
  // ---
  Future<void> _loadTasksFromDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJsonString = prefs.getString('cbtis47_tasks_key');

    if (tasksJsonString != null) {
      List<dynamic> decodedJsonList = jsonDecode(tasksJsonString);
      setState(() {
        tasks = decodedJsonList
            .map((jsonItem) => Task.fromJson(jsonItem))
            .toList();
      });
    }
  }

  // ---
  // DATA PERSISTENCE: SAVE (WRITE)
  // ---
  Future<void> _saveTasksToDevice() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList = tasks
        .map((task) => task.toJson())
        .toList();
    String tasksString = jsonEncode(jsonList);
    await prefs.setString('cbtis47_tasks_key', tasksString);
  }

  // ---
  // MODAL BOTTOM SHEET (CREATE & UPDATE)
  // ---
  void _showTaskModal(BuildContext context, [Task? existingTask]) {
    // Inject existing data if editing, or clear if creating a new task
    if (existingTask != null) {
      _titleController.text = existingTask.title;
      _descriptionController.text = existingTask.description;
    } else {
      _titleController.clear();
      _descriptionController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existingTask != null ? 'Edit Task' : 'Add New Task',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
                autofocus: true,
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // Validation: Prevent empty tasks
                    if (_titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task title cannot be empty!'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      if (existingTask != null) {
                        // UPDATE LOGIC
                        existingTask.title = _titleController.text.trim();
                        existingTask.description = _descriptionController.text
                            .trim();
                      } else {
                        // CREATE LOGIC
                        final newTask = Task(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: _titleController.text.trim(),
                          description: _descriptionController.text.trim(),
                          createdAt: DateTime.now(),
                          appUserId: 'user_001',
                          categoryId: 'cat_1',
                        );
                        tasks.insert(0, newTask);
                      }
                    });

                    // SAVE CHANGES TO DEVICE
                    _saveTasksToDevice();

                    Navigator.pop(context); // Close the modal
                  },
                  child: Text(
                    existingTask != null ? 'Update Task' : 'Save Task',
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ---
  // UI BUILDER
  // ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      // Handle empty state gracefully
      body: tasks.isEmpty
          ? const Center(
              child: Text(
                'No tasks yet. Add one!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return Dismissible(
                  key: ValueKey(task.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    final deletedTask = task;
                    final deletedIndex = index;

                    setState(() {
                      tasks.removeAt(index);
                    });

                    // SAVE STATE AFTER DELETION
                    _saveTasksToDevice();

                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Task "${deletedTask.title}" deleted.'),
                        duration: const Duration(seconds: 4),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            setState(() {
                              tasks.insert(deletedIndex, deletedTask);
                            });
                            // SAVE STATE AGAIN IF UNDO IS CLICKED
                            _saveTasksToDevice();
                          },
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    onLongPress: () => _showTaskModal(context, task),
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (bool? newValue) {
                        setState(() {
                          task.isCompleted = newValue ?? false;
                        });
                        // SAVE STATE WHEN CHECKED/UNCHECKED
                        _saveTasksToDevice();
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
                    subtitle: task.description.isNotEmpty
                        ? Text(task.description)
                        : null, // Only show subtitle if there is a description
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskModal(context),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
