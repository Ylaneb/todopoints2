import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/remote_storage_service.dart';
import '../services/storage_service.dart';
import '../widgets/task_tile.dart';
import '../widgets/add_task_modal.dart';

/// Intent to trigger the FAB action (login or add task).
class AddOrLoginIntent extends Intent {
  const AddOrLoginIntent();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  int xp = 0;
  int level = 1;
  User? user;

  @override
  void initState() {
    super.initState();
    // Load local state
    StorageService.loadAll().then((data) {
      setState(() {
        tasks = data.tasks;
        xp = data.xp;
        level = data.level;
      });
    });
    // Listen for auth changes and sync
    FirebaseAuth.instance.authStateChanges().listen((u) {
      setState(() => user = u);
      if (u != null) {
        _syncRemote();
      }
    });
  }

  Future<void> _syncRemote() async {
    final remoteData = await RemoteStorageService.loadAllRemote();
    if (!mounted) return;
    if (remoteData != null) {
      setState(() {
        tasks = remoteData.tasks;
        xp = remoteData.xp;
        level = remoteData.level;
      });
      await StorageService.saveAll(tasks: tasks, xp: xp, level: level);
    } else {
      await RemoteStorageService.saveAllRemote(
        tasks: tasks,
        xp: xp,
        level: level,
      );
    }
  }

  void _addTask(String title) {
    setState(() {
      tasks.insert(0, Task(title: title));
    });
    StorageService.saveAll(tasks: tasks, xp: xp, level: level);
    if (user != null) {
      RemoteStorageService.saveAllRemote(tasks: tasks, xp: xp, level: level);
    }
  }

  void _toggleTask(Task task) {
    setState(() {
      task.isDone = !task.isDone;
      xp += task.isDone ? 5 : -5;
      if (xp < 0) xp = 0;
      if (xp >= 100) {
        level += xp ~/ 100;
        xp %= 100;
      }
    });
    StorageService.saveAll(tasks: tasks, xp: xp, level: level);
    if (user != null) {
      RemoteStorageService.saveAllRemote(tasks: tasks, xp: xp, level: level);
    }
  }

  void _deleteTask(Task task) {
    setState(() {
      if (task.isDone) xp = (xp - 5).clamp(0, xp);
      tasks.remove(task);
    });
    StorageService.saveAll(tasks: tasks, xp: xp, level: level);
    if (user != null) {
      RemoteStorageService.saveAllRemote(tasks: tasks, xp: xp, level: level);
    }
  }

  void _handleFab() async {
    final ctx = context;
    debugPrint('🔑 FAB tapped, user=$user');
    if (user == null) {
      try {
        await AuthService.signInWithGoogle();
        debugPrint('✅ Signed in via FAB: ${AuthService.currentUser?.email}');
      } catch (e) {
        if (!ctx.mounted) return;
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Sign-in required to add tasks')),
        );
        return;
      }
      if (!ctx.mounted) return;
      await _syncRemote();
      return;
    }
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.black,
      builder: (_) => AddTaskModal(onAdd: _addTask),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.keyN): const AddOrLoginIntent(),
      },
      child: Actions(
        actions: {
          AddOrLoginIntent: CallbackAction<AddOrLoginIntent>(
            onInvoke: (intent) {
              _handleFab();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              title: Text('XP: $xp   Level: $level'),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: LinearProgressIndicator(
                    value: xp / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey[900],
                    valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
                  ),
                ),
                Expanded(
                  child: tasks.isEmpty
                      ? const Center(
                          child: Text(
                            'No tasks yet',
                            style: TextStyle(color: Colors.greenAccent),
                          ),
                        )
                      : ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, i) {
                            final task = tasks[i];
                            return TaskTile(
                              task: task,
                              onToggle: () => _toggleTask(task),
                              onDelete: () => _deleteTask(task),
                            );
                          },
                        ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(user == null ? Icons.login : Icons.add),
              onPressed: _handleFab,
            ),
          ),
        ),
      ),
    );
  }
}
