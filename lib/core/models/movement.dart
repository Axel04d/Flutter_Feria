class Movement {
  final int? id;
  final String tipo;         // recarga, cobro, devolucion
  final String uidTarjeta;
  final String? juegoNombre;
  final String? taquillaId;
  final int monto;
  final int saldoAntes;
  final int saldoDespues;
  final DateTime fecha;
  final bool sincronizado;

  Movement({
    this.id,
    required this.tipo,
    required this.uidTarjeta,
    this.juegoNombre,
    this.taquillaId,
    required this.monto,
    required this.saldoAntes,
    required this.saldoDespues,
    required this.fecha,
    this.sincronizado = false,
  });
}
