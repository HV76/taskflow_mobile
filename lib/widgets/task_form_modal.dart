import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/firestore_service.dart';

class TaskFormModal extends StatefulWidget {
  const TaskFormModal({
    super.key,
    required this.firestoreService,
    this.existingTask,
  });

  final FirestoreService firestoreService;
  final TaskModel? existingTask;

  static Future<void> show(
    BuildContext context, {
    required FirestoreService firestoreService,
    TaskModel? existingTask,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) => TaskFormModal(
        firestoreService: firestoreService,
        existingTask: existingTask,
      ),
    );
  }

  @override
  State<TaskFormModal> createState() => _TaskFormModalState();
}

class _TaskFormModalState extends State<TaskFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late TaskPriority _selectedPriority;
  bool _isSaving = false;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final TaskModel? task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');
    _locationController = TextEditingController(text: task?.location ?? '');
    _selectedPriority = task?.priority ?? TaskPriority.media;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        final TaskModel updated = widget.existingTask!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          priority: _selectedPriority,
          updatedAt: DateTime.now(),
        );
        await widget.firestoreService.updateTask(updated);
      } else {
        final TaskModel newTask = TaskModel(
          id: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          status: TaskStatus.pendiente,
          location: _locationController.text.trim(),
          createdAt: DateTime.now(),
        );
        await widget.firestoreService.createTask(newTask);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                _isEditing ? 'Editar orden de trabajo' : 'Nueva orden de trabajo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titulo',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El titulo es obligatorio';
                  }
                  if (value.trim().length < 3) {
                    return 'El titulo debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripcion',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textInputAction: TextInputAction.next,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La descripcion es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Ubicacion',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                textInputAction: TextInputAction.done,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La ubicacion es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Nivel de prioridad',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<TaskPriority>(
                segments: TaskPriority.values
                    .map(
                      (TaskPriority priority) => ButtonSegment<TaskPriority>(
                        value: priority,
                        label: Text(priority.label),
                      ),
                    )
                    .toList(),
                selected: <TaskPriority>{_selectedPriority},
                onSelectionChanged: (Set<TaskPriority> selection) {
                  setState(() => _selectedPriority = selection.first);
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_isEditing ? 'Guardar cambios' : 'Crear orden'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
