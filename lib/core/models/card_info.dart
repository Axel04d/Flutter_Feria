class CardInfo {
  final int type;        // 1, 3, 9
  final int id;          // para taquilla (page 5)
  final int value;       // saldo o 0
  final int checksum;    // page 7

  CardInfo({
    required this.type,
    required this.id,
    required this.value,
    required this.checksum,
  });

  @override
  String toString() {
    return 'CardInfo(type: $type, id: $id, value: $value, checksum: $checksum)';
  }
}
