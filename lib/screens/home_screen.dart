import 'dart:developer';
import 'add_task_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'package:to_do_list/models/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_list/widgets/expandable.dart';
import 'package:to_do_list/screens/auth_screen.dart';
import 'package:to_do_list/services/auth_service.dart';
import 'package:to_do_list/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? selectedPriority;
  bool isGroupedByPriority = false;
  final auth = AuthService.auth.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    auth != null
        ? {context.read<TaskProvider>().backupVisibleTasksToFirebase(auth!.uid), context.read<TaskProvider>().setGuestMode(false)}
        : log('Não esta logado');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciador de Tarefas'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedPriority = value == 'Todas' ? null : value;
              });
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Filtrar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Todas',
                child: Text('Todas'),
              ),
              const PopupMenuItem(
                value: 'Alta',
                child: Text('Alta'),
              ),
              const PopupMenuItem(
                value: 'Media',
                child: Text('Média'),
              ),
              const PopupMenuItem(
                value: 'Baixa',
                child: Text('Baixa'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pendentes'),
            Tab(text: 'Concluídas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(context, isCompleted: false),
          _buildTaskList(context, isCompleted: true),
        ],
      ),
      floatingActionButton: ExpandableFab(
        distance: 112,
        children: [
          // ActionButton(
          //   onPressed: () async {
          //     await Provider.of<TaskProvider>(context, listen: false).handleLogout();
          //   },
          //   icon: const Icon(Icons.tap_and_play),
          // ),
          ActionButton(
            onPressed: () {
              setState(() {
                isGroupedByPriority = !isGroupedByPriority;
              });
            },
            icon: const Icon(Icons.grid_on_outlined),
          ),
          ActionButton(
            onPressed: () {
              auth != null
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen(
                                user: auth!,
                              )),
                    )
                  : Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    );
              ;
            },
            icon: const Icon(Icons.person),
          ),
          ActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTaskScreen()),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, {required bool isCompleted}) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final tasks = isCompleted
            ? context.watch<TaskProvider>().completedTasks
            : context.watch<TaskProvider>().pendingTasks;
        final filteredTasks = selectedPriority == null
            ? tasks
            : tasks.where((task) => task.priority == selectedPriority).toList();

            

        if (filteredTasks.isEmpty) {
          return Center(
            child: Text(
              isCompleted
                  ? 'Nenhuma tarefa concluída.'
                  : 'Nenhuma tarefa pendente.',
            ),
          );
        }
        if (isGroupedByPriority) {
          final Map<String, List<Task>> groupedTasks = {
            'Alta': [],
            'Media': [],
            'Baixa': [],
          };

          for (var task in filteredTasks) {
            groupedTasks[task.priority]?.add(task);
          }

          return ListView(
            children: [
              if (groupedTasks['Alta']!.isNotEmpty) ...[
                _buildPrioritySection('Alta', groupedTasks['Alta']!),
              ],
              if (groupedTasks['Media']!.isNotEmpty) ...[
                _buildPrioritySection('Media', groupedTasks['Media']!),
              ],
              if (groupedTasks['Baixa']!.isNotEmpty) ...[
                _buildPrioritySection('Baixa', groupedTasks['Baixa']!),
              ],
            ],
          );
        } else {
          return ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              log('${filteredTasks[index].userId}\n${filteredTasks[index].id}');
              final task = filteredTasks[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(task.title),
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      context.read<TaskProvider>().updateTask(
                            Task(
                                id: task.id,
                                title: task.title,
                                description: task.description,
                                priority: task.priority,
                                isCompleted: value!,
                                isView: true),
                          );
                    },
                  ),
                  subtitle: Text(
                    'Prioridade: ${task.priority}',
                    style: TextStyle(
                      color: task.priority == 'Alta'
                          ? Colors.red
                          : task.priority == 'Media'
                              ? Colors.orange
                              : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        context.read<TaskProvider>().deleteTask(task.id!);
                      },
                      icon: const Icon(Icons.delete_outline)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddTaskScreen(task: task),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildPrioritySection(String priority, List<Task> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            'Prioridade: $priority',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: priority == 'Alta'
                  ? Colors.red
                  : priority == 'Media'
                      ? Colors.orange
                      : Colors.green,
            ),
          ),
        ),
        ...tasks
            .map((task) => Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(task.title),
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        context.read<TaskProvider>().updateTask(
                              Task(
                                  id: task.id,
                                  title: task.title,
                                  description: task.description,
                                  priority: task.priority,
                                  isCompleted: value!,
                                  isView: true),
                            );
                      },
                    ),
                    subtitle: Text(
                      'Prioridade: ${task.priority}',
                      style: TextStyle(
                        color: task.priority == 'Alta'
                            ? Colors.red
                            : task.priority == 'Media'
                                ? Colors.orange
                                : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          context.read<TaskProvider>().deleteTask(task.id!);
                        },
                        icon: const Icon(Icons.delete_outline)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddTaskScreen(task: task),
                        ),
                      );
                    },
                  ),
                ))
            .toList(),
      ],
    );
  }
}
