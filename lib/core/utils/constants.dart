class AppConstants {
  // NFC map
  static const int nfcPageType = 4;
  static const int nfcPageId = 5;
  static const int nfcPageValue = 6;
  static const int nfcPageChecksum = 7;

  // Types
  static const int cardTypeTaquilla = 1;
  static const int cardTypeCliente = 3;
  static const int cardTypeAdmin = 9;

  // Config keys
  static const String cfgJuegoNombre = 'juego_nombre';
  static const String cfgJuegoPrecio = 'juego_precio';
  static const String cfgTerminalTipo = 'terminal_tipo'; // juego / taquilla
}
