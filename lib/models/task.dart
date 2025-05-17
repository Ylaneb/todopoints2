import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  bool isDone;

  Task({
    String? id,
    required this.title,
    this.isDone = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isDone': isDone,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        isDone: (json['isDone'] as bool?) ?? false,
      );
}
