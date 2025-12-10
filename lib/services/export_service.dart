import 'dart:convert';
import '../core/database/app_database.dart';
import '../core/database/entities/movement_entity.dart';

class ExportService {
  Future<String> exportMovementsToJson({bool onlyUnsynced = false}) async {
    final db = await AppDatabase.instance;
    List<MovementEntity> movements;

    if (onlyUnsynced) {
      movements = await db.movementDao.getUnsynced();
    } else {
      movements = await db.movementDao.getAll();
    }

    final list = movements.map((m) => m.toMap()).toList();
    return jsonEncode({
      'movimientos': list,
      'exported_at': DateTime.now().toIso8601String(),
    });
  }
}
