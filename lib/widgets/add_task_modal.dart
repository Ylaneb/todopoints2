import 'package:flutter/material.dart';

class AddTaskModal extends StatefulWidget {
  final void Function(String) onAdd;

  const AddTaskModal({super.key, required this.onAdd});

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onAdd(text);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'New Task',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontSize: 18, color: Colors.greenAccent),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: Colors.greenAccent),
            decoration: InputDecoration(
              labelText: 'Task Title',
              labelStyle: const TextStyle(
                  color: Colors.greenAccent, fontSize: 12),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.greenAccent, width: 2),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.greenAccent, width: 2),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
