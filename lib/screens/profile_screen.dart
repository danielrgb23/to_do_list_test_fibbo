import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_list/screens/auth_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_list/providers/task_provider.dart';

class ProfileScreen extends StatelessWidget {
  final User user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileScreen({required this.user});

  Future<void> _backupTasks(BuildContext context) async {
    final tasks =
        []; // Pegue as tasks do seu Provider ou do local onde elas estão.
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'tasks': tasks,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Backup realizado com sucesso")));
    } catch (e) {
      print("Erro ao fazer backup: $e");
    }
  }

  Future<void> _retrieveTasks(BuildContext context) async {
    try {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      final tasks = snapshot.data()?['tasks'];
      // Atualize as tasks no seu provider ou onde necessário.
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Tarefas recuperadas")));
    } catch (e) {
      print("Erro ao recuperar as tarefas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Nome: ${user.displayName ?? 'Não disponível'}'),
            Text('Email: ${user.email ?? 'Não disponível'}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text('Sair'),
            ),
            ElevatedButton(
              onPressed: () => _backupTasks(context),
              child: Text('Fazer Backup'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<TaskProvider>(context, listen: false)
                    .restoreTasks(user.uid);
              },
              child: Text('Recuperar Tarefas'),
            ),
          ],
        ),
      ),
    );
  }
}
