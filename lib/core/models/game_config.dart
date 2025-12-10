class GameConfig {
  final String? juegoNombre;
  final int? juegoPrecio;
  final String? terminalTipo; // 'juego' o 'taquilla'

  GameConfig({
    this.juegoNombre,
    this.juegoPrecio,
    this.terminalTipo,
  });

  GameConfig copyWith({
    String? juegoNombre,
    int? juegoPrecio,
    String? terminalTipo,
  }) {
    return GameConfig(
      juegoNombre: juegoNombre ?? this.juegoNombre,
      juegoPrecio: juegoPrecio ?? this.juegoPrecio,
      terminalTipo: terminalTipo ?? this.terminalTipo,
    );
  }
}
