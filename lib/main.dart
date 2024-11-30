import 'screens/home_screen.dart';
import 'providers/task_provider.dart';
import 'screens/add_task_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:to_do_list/screens/auth_screen.dart';
import 'package:to_do_list/services/auth_service.dart';


//TODO: Ajute no design/layout e adicionar animações
//TODO: Adicionar testes

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final auth = AuthService.auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To do List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      home: auth != null ? HomeScreen() : const AuthScreen(),
      
    );
  }
}
