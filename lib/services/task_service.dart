import '../models/task.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  Database? _database;
  String _currentUserId = 'guest';

  TaskService._internal();

  factory TaskService() => _instance;

  void setUserId(String userId) {
    _currentUserId = userId;
    _database = null;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(
        dbPath, '$_currentUserId-tasks.db');

    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          priority TEXT,
          isCompleted INTEGER,
          isView INTEGER,
          userId TEXT
        )
      ''');
      },
      version: 6,
    );
  }

  Future<List<Task>> fetchTasks({bool showAll = false}) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: showAll ? null : 'isView = ?',
      whereArgs: showAll ? null : [1],
    );

    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<void> addTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap());
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db
        .update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> toggleTaskVisibility(int id, bool isView) async {
    final db = await database;
    await db.update(
      'tasks',
      {'isView': isView ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> restoreTasksFromFirebase(List<Task> firebaseTasks) async {
    final db = await database;

    for (var task in firebaseTasks) {
      final List<Map<String, dynamic>> existingTasks = await db.query(
        'tasks',
        where: 'id = ?',
        whereArgs: [task.id],
      );

      if (existingTasks.isNotEmpty) {
        await db.update(
          'tasks',
          {'isView': 1},
          where: 'id = ?',
          whereArgs: [task.id],
        );
      } else {
        await db.insert('tasks', task.toMap());
      }
    }
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteGuestTasks() async {
    final db = await database;
    await db.delete('tasks', where: 'userId IS NULL');
  }

  Future<void> clearLocalData() async {
    final db = await database;
    await db.delete('tasks');
  }
}
