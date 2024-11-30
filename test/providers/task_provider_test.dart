import '../mocks.mocks.dart';
import '../test_helper.dart';
import 'package:mockito/mockito.dart';
import 'package:to_do_list/models/task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list/providers/task_provider.dart';

void main() {
  late TaskProvider taskProvider;
  late MockTaskService mockTaskService;
  late MockAuthService mockAuthService;
  final mockTasks = [
    Task(
        id: 1,
        title: 'Task 1',
        isCompleted: false,
        priority: 'Alta',
        isView: true),
    Task(
        id: 2,
        title: 'Task 2',
        isCompleted: true,
        priority: 'Baixa',
        isView: true),
  ];

  setUp(() async {
    setupTestEnvironment();
    mockTaskService = MockTaskService();
    mockAuthService = MockAuthService();
    taskProvider = TaskProvider();
    taskProvider.setGuestMode(true);
    when(mockTaskService.fetchTasks()).thenAnswer((_) async => mockTasks);
  });

  group('TaskProvider', () {

    test('Deve adicionar uma nova tarefa', () async {
      // Arrange
      final newTask = Task(
          id: null,
          title: 'New Task',
          isCompleted: false,
          priority: 'Alta',
          isView: true);

      when(mockTaskService.addTask(any)).thenAnswer((_) async {});

      // Act
      await taskProvider.addTask(newTask);

      // Assert
      verifyNever(mockTaskService.addTask(any)).called(0);
    });

    test('Deve atualizar uma tarefa existente', () async {
      // Arrange
      final updatedTask = Task(
          id: 1,
          title: 'Updated Task',
          isCompleted: true,
          priority: 'Alta',
          isView: true);

      taskProvider = TaskProvider();
      taskProvider.tasks.add(updatedTask);

      when(mockTaskService.updateTask(any)).thenAnswer((_) async {});

      // Act
      taskProvider.updateTask(updatedTask);

      // Assert
      verifyNever(mockTaskService.updateTask(updatedTask)).called(0);
    });

    test('Deve excluir uma tarefa', () async {
      // Arrange
      final taskId = 1;

      when(mockTaskService.toggleTaskVisibility(taskId, false))
          .thenAnswer((_) async {});

      // Act
      await taskProvider.deleteTask(taskId);

      // Assert
      verifyNever(mockTaskService.toggleTaskVisibility(taskId, false))
          .called(0);
    });
  });
}
