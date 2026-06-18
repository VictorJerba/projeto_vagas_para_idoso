import 'package:sqflite/sqflite.dart';
import '../model/problema.dart';

class DatabaseProvider {
  static const _dbName = 'vagas_acessiveis.db'; // Nome do  banco
  static const _dbVersion = 1;

  DatabaseProvider.init();

  static final DatabaseProvider instance = DatabaseProvider.init();

  Database? _database;

  Future<Database> get database async {
    if (_database == null) {
      _database = await _initDatabase();
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasePath = await getDatabasesPath();
    String dbPath = '$databasePath/$_dbName';
    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,

    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
        '''
      CREATE TABLE ${Problema.NOME_TABELA} (
      ${Problema.CAMPO_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${Problema.CAMPO_TIPO} TEXT NOT NULL,
      ${Problema.CAMPO_DATA} TEXT,
      ${Problema.CAMPO_RESOLVIDO} INTEGER NOT NULL DEFAULT 0);
      '''
    );
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}