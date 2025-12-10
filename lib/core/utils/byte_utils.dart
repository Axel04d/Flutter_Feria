class ByteUtils {
  // Convierte int saldo a bytes si más adelante lo necesitas por bloques.
  static List<int> intTo4Bytes(int value) {
    return [
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ];
  }

  static int bytesToInt(List<int> bytes) {
    if (bytes.length < 4) {
      throw ArgumentError('Se requieren 4 bytes');
    }
    return (bytes[0] << 24) |
        (bytes[1] << 16) |
        (bytes[2] << 8) |
        (bytes[3]);
  }
}
