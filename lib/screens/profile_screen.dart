import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_list/providers/task_provider.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TaskProvider taskProvider = TaskProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Nome: ${widget.user.displayName ?? 'Não disponível'}'),
            Text('Email: ${widget.user.email ?? 'Não disponível'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Provider.of<TaskProvider>(context, listen: false)
                    .handleLogout()
                    .then((onValue) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (Route<dynamic> route) => false,
                  );
                });
              },
              child: const Text('Sair'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<TaskProvider>(context, listen: false)
                    .backupVisibleTasksToFirebase(widget.user.uid);
                Navigator.pop(context);
              },
              child: const Text('Fazer Backup'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<TaskProvider>(context, listen: false)
                    .restoreTasksFromFirebase(widget.user.uid);
                Navigator.pop(context);
              },
              child: Text('Recuperar Tarefas'),
            ),
          ],
        ),
      ),
    );
  }
}
