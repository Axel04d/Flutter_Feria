import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../models/card_info.dart';
import 'tag_parser.dart';
import '../utils/constants.dart';

typedef OnTagRead = void Function(CardInfo card);

class NFCReader extends StatefulWidget {
  final Widget child;
  final OnTagRead onTagRead;

  const NFCReader({
    super.key,
    required this.child,
    required this.onTagRead,
  });

  @override
  State<NFCReader> createState() => _NFCReaderState();
}

class _NFCReaderState extends State<NFCReader> {
  bool _isAvailable = false;
  bool _sessionStarted = false;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final available = await NfcManager.instance.isAvailable();
    setState(() {
      _isAvailable = available;
    });
    if (available) {
      _startSession();
    }
  }

  void _startSession() {
    if (_sessionStarted) return;
    _sessionStarted = true;

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          final card = await _readCard(tag);
          if (!mounted) return;
          widget.onTagRead(card);
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error leyendo tarjeta: $e')),
          );
        } finally {
          // Cerramos la sesión y permitimos iniciar otra
          await NfcManager.instance.stopSession();
          _sessionStarted = false;
          if (mounted) {
            // Reiniciamos para leer otra tarjeta sin cerrar pantalla
            _startSession();
          }
        }
      },
    );
  }

  /// Lee las páginas 4–7 usando comandos de Mifare Ultralight / NfcA.
  Future<CardInfo> _readCard(NfcTag tag) async {
    final nfcA = NfcA.from(tag);
    if (nfcA == null) {
      throw Exception('Tag no soporta NfcA / MifareUltralight');
    }

    // Comando 0x30 (READ) desde la página 4.
    // Devuelve 16 bytes = 4 páginas (4,5,6,7).
    final cmd = Uint8List.fromList([0x30, AppConstants.nfcPageType]);
    final response = await nfcA.transceive(cmd);

    if (response.length < 16) {
      throw Exception('Respuesta NFC incompleta (se esperaban 16 bytes)');
    }

    // Cada página son 4 bytes.
    // p4 -> bytes 0..3
    // p5 -> bytes 4..7
    // p6 -> bytes 8..11
    // p7 -> bytes 12..15
    final pages = <int, int>{
      AppConstants.nfcPageType: response[0],   // byte 0
      AppConstants.nfcPageId: response[4],     // byte 4
      AppConstants.nfcPageValue: response[8],  // byte 8
      AppConstants.nfcPageChecksum: response[12], // byte 12
    };

    final card = TagParser.parse(pages);
    return card;
  }

  @override
  void dispose() {
    if (_sessionStarted) {
      NfcManager.instance.stopSession();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) {
      return Center(
        child: Text(
          'NFC no disponible en este dispositivo',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return widget.child;
  }
}
