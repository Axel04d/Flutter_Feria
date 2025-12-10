class ConfigEntity {
  static const String tableName = 'config_local';

  final String clave;
  final String valor;

  ConfigEntity({
    required this.clave,
    required this.valor,
  });

  Map<String, dynamic> toMap() {
    return {
      'clave': clave,
      'valor': valor,
    };
  }

  factory ConfigEntity.fromMap(Map<String, dynamic> map) {
    return ConfigEntity(
      clave: map['clave'] as String,
      valor: map['valor'] as String,
    );
  }
}
