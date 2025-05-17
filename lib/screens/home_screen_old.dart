import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/remote_storage_service.dart';
import '../services/auth_service.dart';
import '../widgets/task_tile.dart';
import '../widgets/add_task_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

  /// Intent to trigger the FAB action (add-or-login).
class AddOrLoginIntent extends Intent {
  const AddOrLoginIntent();
}

  State<HomeScreen> createState() => _HomeScreenState();

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  void _handleFab() async {
  final ctx = context;
  if (user == null) {
    // sign-in flow...
    return;
  }
  // user is signed in → open add-task sheet
  showModalBottomSheet(
    context: ctx,
    backgroundColor: Colors.black,
    builder: (_) => AddTaskModal(onAdd: _addTask),
  );
}

  int xp = 0;
  int level = 1;
  User? user; //track signed in user


  Future<void> _syncRemote() async {
  final remoteData = await RemoteStorageService.loadAllRemote();
  if (!mounted) return;
  if (remoteData != null) {
    setState(() {
      tasks = remoteData.tasks;
      xp    = remoteData.xp;
      level = remoteData.level;
    });
    await StorageService.saveAll(tasks: tasks, xp: xp, level: level);
  } else {
    await RemoteStorageService.saveAllRemote(
      tasks: tasks, xp: xp, level: level);
  }
}


  @override
void initState() {
  super.initState();
  // load local
  StorageService.loadAll().then((data) {
    setState(() {
      tasks = data.tasks;
      xp    = data.xp;
      level = data.level;
    });
  });
  // listen for login/logout
  FirebaseAuth.instance.authStateChanges().listen((u) {
    setState(() => user = u);
  });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text('XP: $xp   Level: $level'),
),



      body: Column(
        children: [
          // XP progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: LinearProgressIndicator(
              value: xp / 100,
              minHeight: 12,
              backgroundColor: Colors.grey[900],
              valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
            ),
          ),

          // Task list or empty state
          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Text('No tasks yet',
                        style: TextStyle(color: Colors.greenAccent)))
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

      // Add Task FAB
      floatingActionButton: FloatingActionButton(
  // Show ✏️ when signed in, 🔑 when not
  child: Icon(user == null ? Icons.login : Icons.add),
  onPressed: () async {
    final ctx = context;
    // If not signed in → prompt login & sync
    if (user == null) {
      debugPrint('🔑 FAB tapped, user=null → signing in first');
      try {
        await AuthService.signInWithGoogle();
        debugPrint('✅ Signed in via FAB: ${AuthService.currentUser?.email}');
      } catch (e) {
        if (!ctx.mounted) return;
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Sign-in required to add tasks')),
        );
        return;
      }
      // After login, sync remote
      if (!ctx.mounted) return;
      await _syncRemote();
      return;
    }

    // Otherwise (user != null) → open Add-Task modal
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.black,
      builder: (_) => AddTaskModal(onAdd: _addTask),
    );
  },
),

    );
  }
}