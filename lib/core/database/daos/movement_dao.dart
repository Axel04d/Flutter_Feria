import 'package:sqflite/sqflite.dart';
import '../entities/movement_entity.dart';

class MovementDao {
  final Database db;

  MovementDao(this.db);

  Future<int> insertMovement(MovementEntity movement) async {
    return await db.insert(
      MovementEntity.tableName,
      movement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MovementEntity>> getAll() async {
    final maps = await db.query(
      MovementEntity.tableName,
      orderBy: 'fecha DESC',
    );
    return maps.map((e) => MovementEntity.fromMap(e)).toList();
  }

  Future<List<MovementEntity>> getUnsynced() async {
    final maps = await db.query(
      MovementEntity.tableName,
      where: 'sincronizado = ?',
      whereArgs: [0],
      orderBy: 'fecha ASC',
    );
    return maps.map((e) => MovementEntity.fromMap(e)).toList();
  }

  Future<int> markAsSynced(List<int> ids) async {
    if (ids.isEmpty) return 0;
    final idsStr = ids.join(',');
    return await db.rawUpdate(
      'UPDATE ${MovementEntity.tableName} SET sincronizado = 1 WHERE id IN ($idsStr)',
    );
  }
}
