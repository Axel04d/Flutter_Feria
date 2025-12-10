class ByteUtils {
  // Convierte int a 4 bytes (si algún día usas más memoria)
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

  /// Convierte UID (bytes) a HEX legible: "04:3A:C7:2A:87:6C:80"
  static String bytesToHex(List<int> bytes, {String separator = ':'}) {
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(separator);
  }
}
