// lib/services/remote_storage_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class RemoteStorageService {
  static final _firestore = FirebaseFirestore.instance;

  /// Save tasks, xp & level under `/users/{uid}`.
  static Future<void> saveAllRemote({
    required List<Task> tasks,
    required int xp,
    required int level,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).set({
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'xp': xp,
      'level': level,
    });
  }

  /// Load tasks, xp & level; returns null if no record.
  static Future<({
    List<Task> tasks,
    int xp,
    int level,
  })?> loadAllRemote() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final snap = await _firestore.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    final data = snap.data()!;
    return (
      tasks: (data['tasks'] as List)
          .cast<Map<String, dynamic>>()
          .map(Task.fromJson)
          .toList(),
      xp: (data['xp'] as num).toInt(),
      level: (data['level'] as num).toInt(),
    );
  }
}
