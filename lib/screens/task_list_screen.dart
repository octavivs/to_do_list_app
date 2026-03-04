import 'package:flutter/material.dart';
import '../models/task.dart';
import '../data/mock_data.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // Bring the list of tasks from our MockData class
  final List<Task> tasks = MockData.myTasks;

  // FLUTTER CONCEPT: TextEditingController
  // These controllers act like a bridge between the UI (the text fields)
  // and our logic. They allow us to read what the user types in real-time.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // ---
  // MODAL BOTTOM SHEET METHOD (USER STORY #1 & #4)
  // ---
  // OOP & FLUTTER CONCEPT: Optional Parameters
  // By putting [Task? existingTask] in brackets with a question mark, we tell Dart:
  // "You might receive a task to edit, or it might be 'null' if we are creating a new one."
  void _showTaskModal(BuildContext context, [Task? existingTask]) {
    // LOGIC: CREATE vs. UPDATE
    // If we received an existing task, we inject its data into the text controllers.
    // If not, we clear the controllers so they are completely empty.
    if (existingTask != null) {
      _titleController.text = existingTask.title;
      _descriptionController.text = existingTask.description;
    } else {
      _titleController.clear();
      _descriptionController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the modal to resize when the keyboard appears
      builder: (BuildContext ctx) {
        // UI CONCEPT: Padding & MediaQuery (The Keyboard Trick)
        // We add dynamic padding to the bottom exactly equal to the keyboard's height.
        // This pushes the entire modal up so the input fields are never hidden!
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
              // DYNAMIC UI: Change the title based on the action
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
                autofocus: true, // UX DETAIL: Automatically opens the keyboard
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity, // Makes the button stretch full-width
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
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
                        // USER STORY #4: UPDATE OPERATION
                        // If it's an existing task, we just update its properties.
                        existingTask.title = _titleController.text.trim();
                        existingTask.description = _descriptionController.text
                            .trim();
                      } else {
                        // USER STORY #1: CREATE OPERATION
                        // If it's null, we create a brand new object.
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

                    Navigator.pop(context);
                  },
                  // DYNAMIC UI: Change the button text
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      // FLUTTER CONCEPT: ListView.builder
      // This is the most efficient way to create a list in Flutter.
      // It only renders the items that are visible on the screen!
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          // We get the specific task object for this position (index)
          final task = tasks[index];

          // ---
          // USER STORY #3: TASK DELETION (SWIPE TO DELETE)
          // ---
          // FLUTTER CONCEPT: Dismissible
          // A widget that can be dismissed by dragging in the indicated direction.
          return Dismissible(
            key: ValueKey(task.id),
            direction: DismissDirection.endToStart,

            // UI CONCEPT: Background
            // This is what shows UP BEHIND the list item when you start swiping.
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),

            // EVENT: onDismissed
            // This code runs AFTER the user finishes the swipe gesture.
            onDismissed: (direction) {
              // 1. TEMPORARY MEMORY: We save the task and its position before deleting it.
              // This is crucial for the "Undo" functionality.
              final deletedTask = task;
              final deletedIndex = index;

              // 2. STATE UPDATE: Remove the item from our list so the UI updates.
              setState(() {
                tasks.removeAt(index);
              });

              // 3. USER EXPERIENCE (UX): ScaffoldMessenger & SnackBar
              // We show a temporary pop-up message at the bottom of the screen.
              ScaffoldMessenger.of(
                context,
              ).clearSnackBars(); // Clears any existing snackbars
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Task "${deletedTask.title}" deleted.'),
                  duration: const Duration(seconds: 4), // Grace period
                  // USER STORY #3: ACCEPTANCE CRITERIA 3 & 4 (UNDO ACTION)
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      // If the user clicks "Undo", we put the task back exactly
                      // where it was before using insert().
                      setState(() {
                        tasks.insert(deletedIndex, deletedTask);
                      });
                    },
                  ),
                ),
              );
            },

            // FLUTTER CONCEPT: GestureDetector / InkWell
            // We use ListTile's built-in onLongPress to trigger the edit mode.
            child: ListTile(
              // USER STORY #4: TRIGGERING THE EDIT MODAL
              onLongPress: () {
                // We call the exact same function, but this time we pass the task!
                _showTaskModal(context, task);
              },
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (bool? newValue) {
                  // OOP & FLUTTER CONCEPT: setState
                  // This function tells Flutter: "Something changed in the data,
                  // please redraw the screen so the user can see it!"
                  setState(() {
                    task.isCompleted = newValue ?? false;
                  });
                },
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  // USER STORY #2: Visual indicator for completion
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: task.isCompleted ? Colors.grey : Colors.black87,
                ),
              ),
              subtitle: Text(task.description),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // USER STORY #1: TRIGGERING THE CREATE MODAL
        // Notice we don't pass any task here, so 'existingTask' will be null.
        onPressed: () => _showTaskModal(context),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
