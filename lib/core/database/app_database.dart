import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'daos/movement_dao.dart';
import 'daos/config_dao.dart';
import 'entities/movement_entity.dart';
import 'entities/config_entity.dart';

class AppDatabase {
  AppDatabase._internal(this._db);

  static Database? _database;
  static AppDatabase? _instance;

  final Database _db;

  static Future<AppDatabase> get instance async {
    if (_instance != null) return _instance!;
    final db = await _openDatabase();
    _instance = AppDatabase._internal(db);
    return _instance!;
  }

  Database get db => _db;

  MovementDao get movementDao => MovementDao(_db);
  ConfigDao get configDao => ConfigDao(_db);

  static Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'atracciones_meneses.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await _createTables(database);
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE ${MovementEntity.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL,
        uid_tarjeta TEXT NOT NULL,
        juego_nombre TEXT,
        taquilla_id TEXT,
        monto INTEGER NOT NULL,
        saldo_antes INTEGER NOT NULL,
        saldo_despues INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        sincronizado INTEGER NOT NULL DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE ${ConfigEntity.tableName} (
        clave TEXT PRIMARY KEY,
        valor TEXT NOT NULL
      );
    ''');
  }
}
