import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../../core/database/app_database.dart';
import '../../core/database/entities/movement_entity.dart';
import '../../core/nfc/nfc_writer.dart';
import '../../core/utils/byte_utils.dart';
import '../../core/utils/constants.dart';
import '../../core/nfc/tag_parser.dart';

class CrearClienteScreen extends StatefulWidget {
  final int taquillaId;

  const CrearClienteScreen({super.key, required this.taquillaId});

  @override
  State<CrearClienteScreen> createState() => _CrearClienteScreenState();
}

class _CrearClienteScreenState extends State<CrearClienteScreen> {
  final TextEditingController _saldoController =
      TextEditingController(text: '0');
  bool _procesando = false;

  @override
  void dispose() {
    _saldoController.dispose();
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

  Future<void> _crearTarjeta() async {
    final saldoInicial = int.tryParse(_saldoController.text) ?? 0;
    if (saldoInicial < 0 || saldoInicial > 255) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo inicial debe estar entre 0 y 255')),
      );
      return;
    }

    setState(() => _procesando = true);

    await NfcManager.instance.startSession(onDiscovered: (tag) async {
      try {
        final writer = NFCWriter();
        await writer.writeClienteCard(tag, saldoInicial: saldoInicial);

        // Leer para obtener UID y confirmar saldo
        final card = await _readCardInfo(tag);
        final nfcA = NfcA.from(tag)!;
        final uidHex = ByteUtils.bytesToHex(nfcA.identifier);

        // Registrar movimiento como "recarga" inicial si saldo > 0
        if (saldoInicial > 0) {
          final db = await AppDatabase.instance;
          await db.movementDao.insertMovement(
            MovementEntity(
              tipo: 'recarga',
              uidTarjeta: uidHex,
              juegoNombre: null,
              taquillaId: widget.taquillaId.toString(),
              monto: saldoInicial,
              saldoAntes: 0,
              saldoDespues: card.value,
              fecha: DateTime.now().toIso8601String(),
              sincronizado: 0,
            ),
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarjeta cliente creada correctamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear tarjeta: $e')),
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
        title: const Text('Crear tarjeta cliente'),
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
                    'Instrucciones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Ingrese el saldo inicial (opcional).\n'
                    '2. Presione "Grabar tarjeta".\n'
                    '3. Acerque una tarjeta en blanco o existente para convertirla en tarjeta de cliente.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
