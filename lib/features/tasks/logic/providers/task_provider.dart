// ---
// STATE MANAGEMENT: task_provider.dart
// PATH: lib/features/tasks/logic/providers/task_provider.dart
// ---
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_list_app/features/tasks/data/models/task.dart';
import 'package:to_do_list_app/features/tasks/data/models/category.dart';
import 'package:to_do_list_app/features/tasks/data/repositories/cloud_storage_repository.dart';

// OOP CONCEPT: Reactive State Management
// This provider now acts as a bridge between the UI and the Cloud.
// It listens to Firebase Authentication to know WHO is logged in, and then
// listens to Firestore to get WHAT tasks belong to that specific user.
class TaskProvider extends ChangeNotifier {
  final CloudStorageRepository _repository = CloudStorageRepository();

  List<Task> _tasks = [];

  // FLUTTER CONCEPT: StreamSubscription
  // We keep a reference to the active connection to the database so we can
  // cleanly close it if the user logs out or the app is closed.
  StreamSubscription<List<Task>>? _tasksSubscription;

  // ---
  // CATEGORIES DATA (MOCK)
  // ---
  final List<Category> _categories = [
    Category(id: 'cat_1', name: 'Work', colorHex: '#FF5733'),
    Category(id: 'cat_2', name: 'Personal', colorHex: '#33FF57'),
    Category(id: 'cat_3', name: 'Motorcycles', colorHex: '#3357FF'),
  ];

  String? _selectedFilterCategoryId;

  String? get selectedFilterCategoryId => _selectedFilterCategoryId;
  List<Category> get categories => _categories;

  void setFilterCategory(String? categoryId) {
    _selectedFilterCategoryId = categoryId;
    notifyListeners();
  }

  Category getCategoryById(String categoryId) {
    return _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => _categories.first,
    );
  }

  // ---
  // ADVANCED GETTERS (Combined Filtering)
  // ---
  List<Task> get _filteredByCategory {
    if (_selectedFilterCategoryId == null) {
      return _tasks;
    }
    return _tasks
        .where((task) => task.categoryId == _selectedFilterCategoryId)
        .toList();
  }

  List<Task> get allTasks => _filteredByCategory;
  List<Task> get pendingTasks =>
      _filteredByCategory.where((task) => !task.isCompleted).toList();
  List<Task> get completedTasks =>
      _filteredByCategory.where((task) => task.isCompleted).toList();

  // ---
  // CONSTRUCTOR: AUTO-INITIALIZATION
  // ---
  TaskProvider() {
    // We listen globally to the user's session.
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // User logged in: Start listening to their specific cloud data stream.
        _listenToCloudTasks(user.uid);
      } else {
        // User logged out: Clear data from memory and stop listening.
        _tasks = [];
        _tasksSubscription?.cancel();
        notifyListeners();
      }
    });
  }

  void _listenToCloudTasks(String userId) {
    // Cancel any previous subscriptions to prevent memory leaks
    _tasksSubscription?.cancel();

    _tasksSubscription = _repository.getTasksStream(userId).listen((tasksList) {
      _tasks = tasksList;
      notifyListeners(); // Tells the UI to rebuild automatically!
    });
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }

  // ---
  // CRUD OPERATIONS (CLOUD CONNECTED)
  // ---
  // Notice how we no longer manually update the '_tasks' list.
  // We send the command to Firebase, and Firebase's Stream updates our list automatically.
  // If the device is offline, Firebase caches the command and updates the UI instantly anyway!

  Future<void> addTask(Task task) async {
    await _repository.addTask(task);
  }

  Future<void> updateTask(Task task) async {
    await _repository.updateTask(task);
  }

  Future<void> toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    await _repository.updateTask(task);
  }

  // We keep returning 'int' just to satisfy the Dismissible's UI requirement,
  // but the real source of truth is now the cloud ordering.
  int deleteTask(Task task) {
    final index = _tasks.indexOf(task);
    _repository.deleteTask(task.id);
    return index;
  }

  // To undo a deletion in the cloud, we simply push the exact same Task object
  // back to the database. Firestore will recreate it with its original ID!
  void undoDelete(int index, Task task) {
    _repository.addTask(task);
  }
}
