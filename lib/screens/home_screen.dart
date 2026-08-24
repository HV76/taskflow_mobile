import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/firestore_service.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  TaskStatus? _statusFilter;

  Future<void> _confirmDelete(BuildContext context, TaskModel task) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Eliminar orden de trabajo'),
        content: Text(
          '¿Seguro que deseas eliminar "${task.title}"? Esta accion no se puede deshacer.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firestoreService.deleteTask(task.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Orden "${task.title}" eliminada')),
        );
      }
    }
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          ChoiceChip(
            label: const Text('Todas'),
            selected: _statusFilter == null,
            onSelected: (_) => setState(() => _statusFilter = null),
          ),
          const SizedBox(width: 8),
          ...TaskStatus.values.map(
            (TaskStatus status) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(status.label),
                selected: _statusFilter == status,
                onSelected: (_) => setState(() => _statusFilter = status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow Mobile'),
        centerTitle: false,
      ),
      body: Column(
        children: <Widget>[
          _buildFilterChips(),
          Expanded(
            child: StreamBuilder<List<TaskModel>>(
              stream: _firestoreService.streamTasks(
                statusFilter: _statusFilter,
              ),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<TaskModel>> snapshot,
              ) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Ocurrio un error al cargar las ordenes:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<TaskModel> tasks = snapshot.data ?? <TaskModel>[];

                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.task_alt_rounded,
                          size: 56,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        const Text('No hay ordenes de trabajo registradas'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 88),
                  itemCount: tasks.length,
                  itemBuilder: (BuildContext context, int index) {
                    final TaskModel task = tasks[index];
                    return TaskCard(
                      task: task,
                      onTap: () => TaskFormModal.show(
                        context,
                        firestoreService: _firestoreService,
                        existingTask: task,
                      ),
                      onStatusChange: (TaskStatus newStatus) =>
                          _firestoreService.updateTaskStatus(
                        task.id,
                        newStatus,
                      ),
                      onDelete: () => _confirmDelete(context, task),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => TaskFormModal.show(
          context,
          firestoreService: _firestoreService,
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva orden'),
      ),
    );
  }
}
