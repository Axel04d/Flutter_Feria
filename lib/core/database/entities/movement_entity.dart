class MovementEntity {
  static const String tableName = 'movimientos';

  final int? id;
  final String tipo;
  final String uidTarjeta;
  final String? juegoNombre;
  final String? taquillaId;
  final int monto;
  final int saldoAntes;
  final int saldoDespues;
  final String fecha;     // ISO8601
  final int sincronizado; // 0 / 1

  MovementEntity({
    this.id,
    required this.tipo,
    required this.uidTarjeta,
    this.juegoNombre,
    this.taquillaId,
    required this.monto,
    required this.saldoAntes,
    required this.saldoDespues,
    required this.fecha,
    required this.sincronizado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'uid_tarjeta': uidTarjeta,
      'juego_nombre': juegoNombre,
      'taquilla_id': taquillaId,
      'monto': monto,
      'saldo_antes': saldoAntes,
      'saldo_despues': saldoDespues,
      'fecha': fecha,
      'sincronizado': sincronizado,
    };
  }

  factory MovementEntity.fromMap(Map<String, dynamic> map) {
    return MovementEntity(
      id: map['id'] as int?,
      tipo: map['tipo'] as String,
      uidTarjeta: map['uid_tarjeta'] as String,
      juegoNombre: map['juego_nombre'] as String?,
      taquillaId: map['taquilla_id'] as String?,
      monto: map['monto'] as int,
      saldoAntes: map['saldo_antes'] as int,
      saldoDespues: map['saldo_despues'] as int,
      fecha: map['fecha'] as String,
      sincronizado: map['sincronizado'] as int,
    );
  }
}
