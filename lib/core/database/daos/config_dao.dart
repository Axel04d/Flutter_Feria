import 'package:sqflite/sqflite.dart';
import '../entities/config_entity.dart';
import '../../models/game_config.dart';
import '../../utils/constants.dart';

class ConfigDao {
  final Database db;

  ConfigDao(this.db);

  Future<void> setValue(String clave, String valor) async {
    await db.insert(
      ConfigEntity.tableName,
      ConfigEntity(clave: clave, valor: valor).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getValue(String clave) async {
    final maps = await db.query(
      ConfigEntity.tableName,
      where: 'clave = ?',
      whereArgs: [clave],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ConfigEntity.fromMap(maps.first).valor;
  }

  Future<GameConfig> getCurrentGameConfig() async {
    final nombre = await getValue(AppConstants.cfgJuegoNombre);
    final precioStr = await getValue(AppConstants.cfgJuegoPrecio);
    final tipo = await getValue(AppConstants.cfgTerminalTipo);

    return GameConfig(
      juegoNombre: nombre,
      juegoPrecio: precioStr != null ? int.tryParse(precioStr) : null,
      terminalTipo: tipo,
    );
  }

  Future<void> saveGameConfig(GameConfig config) async {
    if (config.juegoNombre != null) {
      await setValue(AppConstants.cfgJuegoNombre, config.juegoNombre!);
    }
    if (config.juegoPrecio != null) {
      await setValue(AppConstants.cfgJuegoPrecio, config.juegoPrecio.toString());
    }
    if (config.terminalTipo != null) {
      await setValue(AppConstants.cfgTerminalTipo, config.terminalTipo!);
    }
  }
}
