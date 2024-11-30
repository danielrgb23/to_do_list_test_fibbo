import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void setupTestEnvironment() {
  // Inicializa o SQLite para testes
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
