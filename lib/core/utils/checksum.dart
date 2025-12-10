class ChecksumUtil {
  static int calcChecksum(int type, int id, int value) {
    return type ^ id ^ value;
  }

  static bool validateChecksum({
    required int type,
    required int id,
    required int value,
    required int checksum,
  }) {
    return calcChecksum(type, id, value) == checksum;
  }
}
