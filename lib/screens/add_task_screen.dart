import '../models/task.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;
  final String? userId;

  const AddTaskScreen({Key? key, this.task, this.userId}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _priority = 'Alta';

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description ?? '';
      _priority = widget.task!.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Adicionar Tarefa' : 'Editar Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O título é obrigatório';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(
                height: 8,
              ),
              DropdownButtonFormField<String>(
                value: _priority,
                items: ['Alta', 'Media', 'Baixa']
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
                onChanged: (value) => _priority = value!,
                decoration: const InputDecoration(labelText: 'Prioridade'),
              ),
              const SizedBox(
                height: 12,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()),
                maxLines: 3,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final task = Task(
                      id: widget.task?.id,
                      title: _title,
                      description: _description,
                      priority: _priority,
                      isCompleted: widget.task?.isCompleted ?? false,
                      isView: true,
                    );

                    if (widget.task == null) {
                      context.read<TaskProvider>().addTask(task);
                    } else {
                      context.read<TaskProvider>().updateTask(task);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(widget.task == null ? 'Salvar' : 'Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
