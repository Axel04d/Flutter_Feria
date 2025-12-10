import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../../core/database/app_database.dart';
import '../../core/database/entities/movement_entity.dart';
import '../../core/nfc/nfc_writer.dart';
import '../../core/nfc/tag_parser.dart';
import '../../core/utils/byte_utils.dart';
import '../../core/utils/constants.dart';

class RecargarScreen extends StatefulWidget {
  final int taquillaId;

  const RecargarScreen({super.key, required this.taquillaId});

  @override
  State<RecargarScreen> createState() => _RecargarScreenState();
}

class _RecargarScreenState extends State<RecargarScreen> {
  final TextEditingController _montoController = TextEditingController();
  bool _procesando = false;

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

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

  Future<void> _aplicarRecarga() async {
    final monto = int.tryParse(_montoController.text) ?? 0;
    if (monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un monto válido mayor a 0')),
      );
      return;
    }

    setState(() => _procesando = true);

    await NfcManager.instance.startSession(onDiscovered: (tag) async {
      try {
        final card = await _readCardInfo(tag);
        final nfcA = NfcA.from(tag)!;
        final uidHex = ByteUtils.bytesToHex(nfcA.identifier);

        if (card.type != AppConstants.cardTypeCliente) {
          throw Exception('La tarjeta no es de CLIENTE (type=3)');
        }

        final saldoAntes = card.value;
        final nuevoSaldo = saldoAntes + monto;
        if (nuevoSaldo > 255) {
          throw Exception(
              'El saldo resultante excede el máximo permitido (255).');
        }

        final writer = NFCWriter();
        await writer.updateClienteSaldo(tag, nuevoSaldo);

        // Registrar movimiento en SQLite
        final db = await AppDatabase.instance;
        await db.movementDao.insertMovement(
          MovementEntity(
            tipo: 'recarga',
            uidTarjeta: uidHex,
            juegoNombre: null,
            taquillaId: widget.taquillaId.toString(),
            monto: monto,
            saldoAntes: saldoAntes,
            saldoDespues: nuevoSaldo,
            fecha: DateTime.now().toIso8601String(),
            sincronizado: 0,
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Recarga aplicada. Nuevo saldo: \$ $nuevoSaldo')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error en la recarga: $e')),
          );
        }
      } finally {
        await NfcManager.instance.stopSession();
        if (mounted) {
          setState(() => _procesando = false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Recargar saldo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Paso 1',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ingrese el monto a recargar.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Paso 2',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Presione "Aplicar recarga" y acerque la tarjeta del cliente.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto a recargar (0–255)',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _procesando ? null : _aplicarRecarga,
              icon: const Icon(Icons.nfc),
              label: Text(
                _procesando
                    ? 'Acerque la tarjeta...'
                    : 'Aplicar recarga y leer tarjeta',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
