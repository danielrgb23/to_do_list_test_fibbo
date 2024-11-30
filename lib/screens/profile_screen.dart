import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_list/screens/auth_screen.dart';
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
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '${widget.user.displayName ?? 'Não disponível'}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${widget.user.email ?? 'Não disponível'}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await Provider.of<TaskProvider>(context, listen: false)
                      .restoreTasksFromFirebase(widget.user.uid);
                  Navigator.pop(context);
                },
                child: Text('Recuperar Tarefas'),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<TaskProvider>(context, listen: false)
                      .backupVisibleTasksToFirebase(widget.user.uid);
                  Navigator.pop(context);
                },
                child: const Text('Fazer Backup'),
              ),
              TextButton(
                onPressed: () async {
                  Provider.of<TaskProvider>(context, listen: false)
                      .handleLogout()
                      .then((onValue) {
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) {
                      return const AuthScreen();
                    }), (Route<dynamic> route) => false);
                  });
                },
                child: const Text('Sair'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
