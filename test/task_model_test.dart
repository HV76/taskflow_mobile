import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_mobile/models/task_model.dart';

void main() {
  group('TaskPriority', () {
    test('fromString convierte correctamente cada valor valido', () {
      expect(TaskPriorityX.fromString('Baja'), TaskPriority.baja);
      expect(TaskPriorityX.fromString('media'), TaskPriority.media);
      expect(TaskPriorityX.fromString('ALTA'), TaskPriority.alta);
      expect(TaskPriorityX.fromString('Critica'), TaskPriority.critica);
    });

    test('fromString retorna media como valor por defecto si es invalido', () {
      expect(TaskPriorityX.fromString('inexistente'), TaskPriority.media);
    });

    test('label retorna el texto legible correcto', () {
      expect(TaskPriority.baja.label, 'Baja');
      expect(TaskPriority.critica.label, 'Critica');
    });
  });

  group('TaskStatus', () {
    test('fromString convierte correctamente cada valor valido', () {
      expect(TaskStatusX.fromString('Pendiente'), TaskStatus.pendiente);
      expect(TaskStatusX.fromString('En Progreso'), TaskStatus.enProgreso);
      expect(TaskStatusX.fromString('completado'), TaskStatus.completado);
    });

    test('fromString retorna pendiente como valor por defecto si es invalido',
        () {
      expect(TaskStatusX.fromString('desconocido'), TaskStatus.pendiente);
    });
  });

  group('TaskModel', () {
    TaskModel buildTask({
      String title = 'Revisar servidor',
      String description = 'El servidor principal no responde',
      TaskPriority priority = TaskPriority.alta,
      TaskStatus status = TaskStatus.pendiente,
      String location = 'Sala de servidores',
    }) {
      return TaskModel(
        id: 'task-001',
        title: title,
        description: description,
        priority: priority,
        status: status,
        location: location,
        createdAt: DateTime(2026, 1, 15, 9, 30),
      );
    }

    test('isValid retorna true cuando titulo y descripcion son validos', () {
      final TaskModel task = buildTask();
      expect(task.isValid(), isTrue);
    });

    test('isValid retorna false cuando el titulo esta vacio', () {
      final TaskModel task = buildTask(title: '   ');
      expect(task.isValid(), isFalse);
    });

    test('isValid retorna false cuando la descripcion esta vacia', () {
      final TaskModel task = buildTask(description: '');
      expect(task.isValid(), isFalse);
    });

    test('toMap produce un mapa serializable con los campos esperados', () {
      final TaskModel task = buildTask();
      final Map<String, dynamic> map = task.toMap();

      expect(map['title'], 'Revisar servidor');
      expect(map['description'], 'El servidor principal no responde');
      expect(map['priority'], 'Alta');
      expect(map['status'], 'Pendiente');
      expect(map['location'], 'Sala de servidores');
      expect(map['updatedAt'], isNull);
    });

    test('copyWith actualiza solo los campos indicados', () {
      final TaskModel original = buildTask();
      final DateTime updateTime = DateTime(2026, 1, 16, 10);

      final TaskModel updated = original.copyWith(
        status: TaskStatus.enProgreso,
        updatedAt: updateTime,
      );

      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(updated.status, TaskStatus.enProgreso);
      expect(updated.updatedAt, updateTime);
      expect(original.status, TaskStatus.pendiente,
          reason: 'La instancia original no debe mutar');
    });

    test('copyWith sin argumentos conserva todos los valores originales', () {
      final TaskModel original = buildTask();
      final TaskModel copy = original.copyWith();

      expect(copy.title, original.title);
      expect(copy.description, original.description);
      expect(copy.priority, original.priority);
      expect(copy.status, original.status);
      expect(copy.location, original.location);
      expect(copy.createdAt, original.createdAt);
    });
  });
}
