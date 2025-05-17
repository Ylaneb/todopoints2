import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onToggle,
        leading: Checkbox(
          value: task.isDone,
          onChanged: (_) => onToggle(),
          side: const BorderSide(color: Colors.greenAccent, width: 2),
          fillColor: WidgetStateProperty.all(Colors.greenAccent),
          checkColor: Colors.black,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.greenAccent,
            decoration:
                task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
