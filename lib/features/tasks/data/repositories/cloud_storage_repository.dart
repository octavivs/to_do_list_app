// ---
// REPOSITORY: cloud_storage_repository.dart
// PATH: lib/features/tasks/data/repositories/cloud_storage_repository.dart
// ---
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_list_app/features/tasks/data/models/task.dart';

// OOP CONCEPT: Cloud Data Layer
// This repository handles all CRUD operations with Firebase Cloud Firestore.
// It abstracts the network calls and offline-caching mechanisms provided by Firebase.
class CloudStorageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Defines the main collection name in our NoSQL database
  static const String _collectionPath = 'tasks';

  // ---
  // READ (STREAMING REAL-TIME DATA)
  // ---
  // Instead of a one-time Future, we return a Stream. This allows the app to
  // automatically update the UI if the data changes in the cloud (e.g., from another device).
  // We strictly filter tasks so a user only sees their own data.
  Stream<List<Task>> getTasksStream(String userId) {
    return _firestore
        .collection(_collectionPath)
        .where('appUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            // We inject the document ID into the JSON before parsing
            final data = doc.data();
            data['id'] = doc.id;
            return Task.fromJson(data);
          }).toList();
        });
  }

  // ---
  // CREATE
  // ---
  // Saves a new task to Firestore. If the device is offline, Firebase caches
  // this action locally and executes it when the connection is restored.
  Future<void> addTask(Task task) async {
    await _firestore
        .collection(_collectionPath)
        .doc(task.id)
        .set(task.toJson());
  }

  // ---
  // UPDATE
  // ---
  // Updates an existing document in the cloud.
  Future<void> updateTask(Task task) async {
    await _firestore
        .collection(_collectionPath)
        .doc(task.id)
        .update(task.toJson());
  }

  // ---
  // DELETE
  // ---
  // Removes the document permanently from the cloud database.
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection(_collectionPath).doc(taskId).delete();
  }
}
