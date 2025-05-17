import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class StorageService {
  static const _tasksKey = 'tasks';
  static const _xpKey    = 'xp';
  static const _lvlKey   = 'level';

  /// Persist tasks, xp, level to SharedPreferences
  static Future<void> saveAll({
    required List<Task> tasks,
    required int xp,
    required int level,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tasksKey, jsonEncode(tasks.map((t) => t.toJson()).toList()));
    await prefs.setInt(_xpKey, xp);
    await prefs.setInt(_lvlKey, level);
  }

  /// Load saved tasks, xp, level (defaults if missing)
  static Future<({
    List<Task> tasks,
    int xp,
    int level,
  })> loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    // tasks
    final tasksJson = prefs.getString(_tasksKey);
    final tasks = (tasksJson != null)
        ? (jsonDecode(tasksJson) as List)
            .cast<Map<String, dynamic>>()
            .map(Task.fromJson)
            .toList()
        : <Task>[];

    // xp & level
    final xp    = prefs.getInt(_xpKey)    ?? 0;
    final level = prefs.getInt(_lvlKey)   ?? 1;

    return (tasks: tasks, xp: xp, level: level);
  }
}
