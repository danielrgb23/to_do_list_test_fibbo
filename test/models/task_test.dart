import 'package:to_do_list/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Task Model Tests', () {
    // Teste do construtor e métodos básicos
    test('Deve criar uma Task corretamente', () {
      final task = Task(
        id: 1,
        title: 'Test Task',
        description: 'Description of task',
        priority: 'High',
        isCompleted: false,
        isView: true,
        userId: 'user123',
      );

      expect(task.id, 1);
      expect(task.title, 'Test Task');
      expect(task.description, 'Description of task');
      expect(task.priority, 'High');
      expect(task.isCompleted, false);
      expect(task.isView, true);
      expect(task.userId, 'user123');
    });

    // Teste do método copyWith()
    test('Deve criar uma cópia de uma Task com alguns valores alterados', () {
      final task = Task(
        id: 1,
        title: 'Test Task',
        description: 'Description of task',
        priority: 'High',
        isCompleted: false,
        isView: true,
        userId: 'user123',
      );

      final updatedTask = task.copyWith(
        title: 'Updated Task',
        isCompleted: true,
      );

      expect(updatedTask.title, 'Updated Task');
      expect(updatedTask.isCompleted, true);
      expect(updatedTask.id, 1);  // O id deve permanecer o mesmo
      expect(updatedTask.description, 'Description of task');  // Não foi alterado
    });

    // Teste do método toMap()
    test('Deve converter uma Task para um Map corretamente', () {
      final task = Task(
        id: 1,
        title: 'Test Task',
        description: 'Description of task',
        priority: 'High',
        isCompleted: false,
        isView: true,
        userId: 'user123',
      );

      final map = task.toMap();

      expect(map['id'], 1);
      expect(map['title'], 'Test Task');
      expect(map['description'], 'Description of task');
      expect(map['priority'], 'High');
      expect(map['isCompleted'], 0);  // false -> 0
      expect(map['isView'], 1);  // true -> 1
      expect(map['userId'], 'user123');
    });

    // Teste do método fromMap()
    test('Deve converter um Map para uma Task corretamente', () {
      final map = {
        'id': 1,
        'title': 'Test Task',
        'description': 'Description of task',
        'priority': 'High',
        'isCompleted': 0,
        'isView': 1,
        'userId': 'user123',
      };

      final task = Task.fromMap(map);

      expect(task.id, 1);
      expect(task.title, 'Test Task');
      expect(task.description, 'Description of task');
      expect(task.priority, 'High');
      expect(task.isCompleted, false);  // 0 -> false
      expect(task.isView, true);  // 1 -> true
      expect(task.userId, 'user123');
    });
  });
}
