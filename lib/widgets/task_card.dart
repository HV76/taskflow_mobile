import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onStatusChange,
    required this.onDelete,
  });

  final TaskModel task;
  final VoidCallback onTap;
  final ValueChanged<TaskStatus> onStatusChange;
  final VoidCallback onDelete;

  Color _priorityColor(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    switch (task.priority) {
      case TaskPriority.baja:
        return Colors.green;
      case TaskPriority.media:
        return Colors.amber.shade700;
      case TaskPriority.alta:
        return Colors.deepOrange;
      case TaskPriority.critica:
        return scheme.error;
    }
  }

  IconData _statusIcon() {
    switch (task.status) {
      case TaskStatus.pendiente:
        return Icons.hourglass_empty_rounded;
      case TaskStatus.enProgreso:
        return Icons.autorenew_rounded;
      case TaskStatus.completado:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _priorityColor(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<TaskStatus>(
                    icon: Icon(_statusIcon(), color: scheme.primary),
                    onSelected: onStatusChange,
                    itemBuilder: (BuildContext context) => TaskStatus.values
                        .map(
                          (TaskStatus status) => PopupMenuItem<TaskStatus>(
                            value: status,
                            child: Text(status.label),
                          ),
                        )
                        .toList(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    tooltip: 'Eliminar',
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: <Widget>[
                  Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: Icon(_statusIcon(), size: 16),
                    label: Text(task.status.label),
                  ),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: const Icon(Icons.priority_high_rounded, size: 16),
                    label: Text(task.priority.label),
                    backgroundColor: _priorityColor(context).withValues(alpha: 0.15),
                  ),
                  if (task.location.isNotEmpty)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: const Icon(Icons.location_on_outlined, size: 16),
                      label: Text(task.location),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Creado: ${formatter.format(task.createdAt)}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
