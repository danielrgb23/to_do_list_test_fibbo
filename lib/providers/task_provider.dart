import '../models/task.dart';
import 'package:flutter/material.dart';
import '../services/task_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  String? _priorityFilter;

  List<Task> get tasks => _tasks;
  String? get priorityFilter => _priorityFilter;

  void setPriorityFilter(String? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  List<Task> get filteredPendingTasks {
    return pendingTasks.where((task) {
      return _priorityFilter == null || task.priority == _priorityFilter;
    }).toList();
  }

  List<Task> get filteredCompletedTasks {
    return completedTasks.where((task) {
      return _priorityFilter == null || task.priority == _priorityFilter;
    }).toList();
  }

  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));

  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));

  Future<void> loadTasks() async {
    _tasks = await _taskService.fetchTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _taskService.addTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      await _taskService.updateTask(updatedTask);
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    await _taskService.deleteTask(id);
    await loadTasks();
  }

  // Fazer backup no Firestore
  Future<void> backupTasks(String userId) async {
    final tasksCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks');

    for (var task in _tasks) {
      await tasksCollection.doc(task.id.toString()).set(task.toMap());
    }
  }

  // Recuperar tarefas do Firestore
  Future<void> restoreTasks(String userId) async {
    final tasksCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks');

    final querySnapshot = await tasksCollection.get();
    _tasks = querySnapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
    loadTasks();
    notifyListeners();
  }
}
