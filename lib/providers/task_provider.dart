import 'dart:math';
import '../models/task.dart';
import 'package:flutter/material.dart';
import '../services/task_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_list/services/auth_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isGuest = true;

  List<Task> get tasks => _tasks;

  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));

  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));

  void setGuestMode(bool isGuest) {
    _isGuest = isGuest;

    _taskService.setUserId(isGuest ? 'guest' : AuthService.user!.uid);

    _tasks.clear();
  }

  Future<void> loadTasks() async {
    _tasks = await _taskService.fetchTasks();

    if (_isGuest) {
      _tasks.removeWhere((task) => task.userId != null);
    }

    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    final userId = _isGuest ? null : AuthService.user?.uid;
    final taskWithUserId = task.copyWith(userId: userId);

    await _taskService.addTask(taskWithUserId);
    loadTasks();
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
    await _taskService.toggleTaskVisibility(id, false);
    await loadTasks();
  }

  Future<void> backupVisibleTasksToFirebase(String userId) async {
    if (_isGuest) return;

    final tasksCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks');

    final tasks =
        _tasks.where((task) => task.userId == userId && task.isView).toList();

    for (var task in tasks) {
      await tasksCollection.doc(task.id.toString()).set(task.toMap());
    }
  }

  Future<void> restoreTasksFromFirebase(String userId) async {
    final tasksCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks');

    final querySnapshot = await tasksCollection.get();
    final firebaseTasks = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Task.fromMap(data..['id'] = int.parse(doc.id));
    }).toList();

    await _taskService.restoreTasksFromFirebase(firebaseTasks);
    loadTasks();
  }

  Future<void> handleLogin(String userId) async {
    setGuestMode(false);

    // Carrega as tarefas após mover do guest para o usuário logado
    await loadTasks();

    // Restaurar tarefas do Firebase
    restoreTasksFromFirebase(userId);
  }

  Future<void> handleLogout() async {
    if (_isGuest == false) {
      await backupVisibleTasksToFirebase(AuthService.user!.uid);
    }

    await clearLocalData();

    await AuthService().logout();

    setGuestMode(true);
    _tasks.clear();
    loadTasks();
    notifyListeners();
  }

  Future<void> clearLocalData() async {
    await _taskService.clearLocalData();
    _tasks.clear();
    notifyListeners();
  }
}
