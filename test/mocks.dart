import 'package:mockito/annotations.dart';
import 'package:to_do_list/services/task_service.dart';
import 'package:to_do_list/services/auth_service.dart';

@GenerateMocks([TaskService, AuthService])
void main() {}
