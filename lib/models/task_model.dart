import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { baja, media, alta, critica }

enum TaskStatus { pendiente, enProgreso, completado }

extension TaskPriorityX on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.baja:
        return 'Baja';
      case TaskPriority.media:
        return 'Media';
      case TaskPriority.alta:
        return 'Alta';
      case TaskPriority.critica:
        return 'Critica';
    }
  }

  static TaskPriority fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'baja':
        return TaskPriority.baja;
      case 'media':
        return TaskPriority.media;
      case 'alta':
        return TaskPriority.alta;
      case 'critica':
        return TaskPriority.critica;
      default:
        return TaskPriority.media;
    }
  }
}

extension TaskStatusX on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.pendiente:
        return 'Pendiente';
      case TaskStatus.enProgreso:
        return 'En Progreso';
      case TaskStatus.completado:
        return 'Completado';
    }
  }

  static TaskStatus fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'pendiente':
        return TaskStatus.pendiente;
      case 'en progreso':
      case 'enprogreso':
        return TaskStatus.enProgreso;
      case 'completado':
        return TaskStatus.completado;
      default:
        return TaskStatus.pendiente;
    }
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final String location;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.location,
    required this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    return TaskModel(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      priority: TaskPriorityX.fromString(
        (data['priority'] as String?) ?? 'Media',
      ),
      status: TaskStatusX.fromString(
        (data['status'] as String?) ?? 'Pendiente',
      ),
      location: (data['location'] as String?) ?? '',
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: (data['updatedAt'] is Timestamp)
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'priority': priority.label,
      'status': status.label,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  TaskModel copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    String? location,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      location: location ?? this.location,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool isValid() {
    return title.trim().isNotEmpty && description.trim().isNotEmpty;
  }
}
