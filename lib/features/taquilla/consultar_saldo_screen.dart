import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../../core/models/card_info.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/byte_utils.dart';
import '../../core/nfc/tag_parser.dart';

class ConsultarSaldoScreen extends StatefulWidget {
  final int taquillaId;

  const ConsultarSaldoScreen({super.key, required this.taquillaId});

  @override
  State<ConsultarSaldoScreen> createState() => _ConsultarSaldoScreenState();
}

class _ConsultarSaldoScreenState extends State<ConsultarSaldoScreen> {
  CardInfo? _card;
  String? _uid;
  bool _leyendo = false;

  Future<CardInfo> _readCardInfo(NfcTag tag) async {
    final nfcA = NfcA.from(tag);
    if (nfcA == null) throw Exception('Tag no soporta NfcA');

    final cmd = Uint8List.fromList([0x30, AppConstants.nfcPageType]);
    final response = await nfcA.transceive(cmd);
    if (response.length < 16) {
      throw Exception('Respuesta NFC incompleta');
    }

    final pages = <int, int>{
      AppConstants.nfcPageType: response[0],
      AppConstants.nfcPageId: response[4],
      AppConstants.nfcPageValue: response[8],
      AppConstants.nfcPageChecksum: response[12],
    };

    return TagParser.parse(pages);
  }

  Future<void> _escanear() async {
    setState(() {
      _leyendo = true;
      _card = null;
      _uid = null;
    });

    await NfcManager.instance.startSession(onDiscovered: (tag) async {
      try {
        final card = await _readCardInfo(tag);
        final nfcA = NfcA.from(tag)!;
        final uid = ByteUtils.bytesToHex(nfcA.identifier);

        if (card.type != AppConstants.cardTypeCliente) {
          throw Exception('La tarjeta no es de CLIENTE (type=3)');
        }

        setState(() {
          _card = card;
          _uid = uid;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarjeta leída correctamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al leer tarjeta: $e')),
          );
        }
      } finally {
        await NfcManager.instance.stopSession();
        if (mounted) {
          setState(() => _leyendo = false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Consultar saldo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _leyendo ? null : _escanear,
              icon: const Icon(Icons.nfc),
              label: Text(
                _leyendo ? 'Acerque la tarjeta...' : 'Escanear tarjeta cliente',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final card = _card;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: card == null
          ? Column(
              children: const [
                Icon(Icons.credit_card, size: 40, color: Colors.blueGrey),
                SizedBox(height: 12),
                Text(
                  'Aún no se ha leído ninguna tarjeta.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Presione el botón y acerque una tarjeta de cliente.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Tarjeta cliente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_uid != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'UID: $_uid',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 18),
                Text(
                  '\$ ${card.value}',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Saldo disponible',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
    );
  }
}
