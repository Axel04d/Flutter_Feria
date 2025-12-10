import 'dart:typed_data';

import 'package:nfc_manager/nfc_manager.dart';

import '../utils/constants.dart';
import 'tag_parser.dart';

class NFCWriter {
  /// Crea/convierte una tarjeta ADMIN (type = 9, id=0, saldo=0)
  Future<void> writeAdminCard(NfcTag tag) async {
    await _writeCard(
      tag,
      type: AppConstants.cardTypeAdmin,
      id: 0,
      value: 0,
    );
  }

  /// Crea/convierte una tarjeta TAQUILLA (type = 1, id = taquillaId, saldo=0)
  Future<void> writeTaquillaCard(NfcTag tag, {required int taquillaId}) async {
    if (taquillaId < 0 || taquillaId > 255) {
      throw ArgumentError('taquillaId debe estar entre 0 y 255');
    }
    await _writeCard(
      tag,
      type: AppConstants.cardTypeTaquilla,
      id: taquillaId,
      value: 0,
    );
  }

  /// Crea/convierte una tarjeta CLIENTE (type = 3, saldoInicial en 0–255)
  Future<void> writeClienteCard(NfcTag tag, {required int saldoInicial}) async {
    if (saldoInicial < 0 || saldoInicial > 255) {
      throw ArgumentError('saldoInicial debe estar entre 0 y 255');
    }
    await _writeCard(
      tag,
      type: AppConstants.cardTypeCliente,
      id: 0,
      value: saldoInicial,
    );
  }

  /// Actualiza el saldo de una tarjeta cliente.
  /// IMPORTANTE: Lógica de negocio (verificar saldo, registrar movimiento, etc.)
  /// se hace en la capa superior (servicio / pantalla).
  Future<void> updateClienteSaldo(NfcTag tag, int nuevoSaldo) async {
    if (nuevoSaldo < 0 || nuevoSaldo > 255) {
      throw ArgumentError('nuevoSaldo debe estar entre 0 y 255');
    }

    // Aquí podrías leer primero type e id para mantenerlos; por simplicidad:
    // asumimos type=3 (cliente) e id=0. Si quieres ser más estricto, lee el tag
    // con NFCReader, verifica, y luego llama a un writer más especializado.
    await _writeCard(
      tag,
      type: AppConstants.cardTypeCliente,
      id: 0,
      value: nuevoSaldo,
    );
  }

  /// Función interna que escribe type, id, value, checksum en páginas 4–7.
  Future<void> _writeCard(
    NfcTag tag, {
    required int type,
    required int id,
    required int value,
  }) async {
    final nfcA = NfcA.from(tag);
    if (nfcA == null) {
      throw Exception('Tag no soporta NfcA / MifareUltralight');
    }

    final pages = TagParser.buildPagesForCard(
      type: type,
      id: id,
      value: value,
    );

    // Cada página en Ultralight son 4 bytes.
    // Nosotros usamos solo el primer byte y dejamos 3 bytes en 0.
    Future<void> writePage(int pageNumber, int firstByte) async {
      final cmd = Uint8List.fromList([
        0xA2, // WRITE
        pageNumber,
        firstByte,
        0x00,
        0x00,
        0x00,
      ]);
      final res = await nfcA.transceive(cmd);

      // La mayoría de los Ultralight devuelven un ACK (0x0A) o NACK (<0x0A).
      if (res.isNotEmpty && res[0] != 0x0A) {
        throw Exception(
            'Error al escribir página $pageNumber (respuesta: ${res[0]})');
      }
    }

    // Escribimos las 4 páginas:
    await writePage(AppConstants.nfcPageType, pages[AppConstants.nfcPageType]!);
    await writePage(AppConstants.nfcPageId, pages[AppConstants.nfcPageId]!);
    await writePage(
        AppConstants.nfcPageValue, pages[AppConstants.nfcPageValue]!);
    await writePage(AppConstants.nfcPageChecksum,
        pages[AppConstants.nfcPageChecksum]!);

    // ignore: avoid_print
    print('Tarjeta escrita correctamente: type=$type id=$id value=$value');
  }
}
