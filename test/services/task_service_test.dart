import '../test_helper.dart';
import 'package:to_do_list/models/task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:to_do_list/services/task_service.dart';


void main() {
  late TaskService taskService;

  // Configura o SQLite para testes
  setUpAll(() {
    setupTestEnvironment();
  });

  // Inicializa o serviço antes de cada teste
  setUp(() async {
    taskService = TaskService();
    taskService.setUserId('test_user');
    await taskService.clearLocalData();
  });

  test('Deve inicializar o banco de dados corretamente', () async {
    final db = await taskService.database;
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='tasks'");
    expect(tables.isNotEmpty, true);
  });

  test('Deve adicionar uma tarefa e recuperá-la', () async {
    final task = Task(
      id: 1,
      title: 'Test Task',
      description: 'Testing addTask',
      priority: 'High',
      isCompleted: false,
      isView: true,
      userId: 'test_user',
    );

    await taskService.addTask(task);
    final tasks = await taskService.fetchTasks(showAll: true);

    expect(tasks.length, 1);
    expect(tasks[0].title, 'Test Task');
  });

  test('Deve atualizar uma tarefa existente', () async {
    final task = Task(
      id: 1,
      title: 'Initial Task',
      description: 'Initial Description',
      priority: 'Low',
      isCompleted: false,
      isView: true,
      userId: 'test_user',
    );

    await taskService.addTask(task);

    final updatedTask = Task(
      id: 1,
      title: 'Updated Task',
      description: 'Updated Description',
      priority: 'High',
      isCompleted: true,
      isView: false,
      userId: 'test_user',
    );

    await taskService.updateTask(updatedTask);
    final tasks = await taskService.fetchTasks(showAll: true);

    expect(tasks.length, 1);
    expect(tasks[0].title, 'Updated Task');
    expect(tasks[0].priority, 'High');
  });

  test('Deve alternar a visibilidade de uma tarefa', () async {
    final task = Task(
      id: 1,
      title: 'Visibility Task',
      description: 'Testing toggle visibility',
      priority: 'Medium',
      isCompleted: false,
      isView: true,
      userId: 'test_user',
    );

    await taskService.addTask(task);
    await taskService.toggleTaskVisibility(1, false);
    final tasks = await taskService.fetchTasks(showAll: false);

    expect(tasks.isEmpty, true);

    await taskService.toggleTaskVisibility(1, true);
    final visibleTasks = await taskService.fetchTasks(showAll: false);

    expect(visibleTasks.length, 1);
  });

  test('Deve deletar uma tarefa corretamente', () async {
    final task = Task(
      id: 1,
      title: 'Task to delete',
      description: 'Testing deleteTask',
      priority: 'Low',
      isCompleted: false,
      isView: true,
      userId: 'test_user',
    );

    await taskService.addTask(task);
    await taskService.deleteTask(1);
    final tasks = await taskService.fetchTasks(showAll: true);

    expect(tasks.isEmpty, true);
  });

  test('Deve limpar dados locais', () async {
    final task1 = Task(
      id: 1,
      title: 'Task 1',
      description: 'First task',
      priority: 'Low',
      isCompleted: false,
      isView: true,
      userId: 'test_user',
    );

    final task2 = Task(
      id: 2,
      title: 'Task 2',
      description: 'Second task',
      priority: 'High',
      isCompleted: true,
      isView: true,
      userId: 'test_user',
    );

    await taskService.addTask(task1);
    await taskService.addTask(task2);

    await taskService.clearLocalData();
    final tasks = await taskService.fetchTasks(showAll: true);

    expect(tasks.isEmpty, true);
  });
}
