import 'package:flutter/material.dart';
import '../../core/models/card_info.dart';

class ReaderScreen extends StatelessWidget {
  final CardInfo card;

  const ReaderScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Información de tarjeta')),
      body: Center(
        child: Text('Tipo: ${card.type} | Valor: ${card.value}'),
      ),
    );
  }
}
