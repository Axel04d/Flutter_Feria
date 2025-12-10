import '../models/card_info.dart';
import '../utils/constants.dart';
import '../utils/checksum.dart';

class TagParser {
  /// Recibe los bytes ya leídos de las páginas 4–7.
  /// `pages` es un map: {pageIndex: firstByteOfPage}
  static CardInfo parse(Map<int, int> pages) {
    final type = pages[AppConstants.nfcPageType] ?? 0;
    final id = pages[AppConstants.nfcPageId] ?? 0;
    final value = pages[AppConstants.nfcPageValue] ?? 0;
    final checksum = pages[AppConstants.nfcPageChecksum] ?? 0;

    final valid = ChecksumUtil.validateChecksum(
      type: type,
      id: id,
      value: value,
      checksum: checksum,
    );

    if (!valid) {
      // Podrías lanzar excepción o marcar la tarjeta como corrupta.
      // Aquí solo avisamos por debug.
      // ignore: avoid_print
      print('Checksum inválido para tarjeta: '
          'type=$type id=$id value=$value checksum=$checksum');
    }

    return CardInfo(
      type: type,
      id: id,
      value: value,
      checksum: checksum,
    );
  }

  /// Construye los bytes (solo el primer byte de cada página) para escribir.
  static Map<int, int> buildPagesForCard({
    required int type,
    required int id,
    required int value,
  }) {
    final checksum = ChecksumUtil.calcChecksum(type, id, value);
    return {
      AppConstants.nfcPageType: type,
      AppConstants.nfcPageId: id,
      AppConstants.nfcPageValue: value,
      AppConstants.nfcPageChecksum: checksum,
    };
  }
}
