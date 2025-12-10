import 'package:flutter/material.dart';
import '../../core/models/card_info.dart';

class TaquillaScreen extends StatelessWidget {
  final CardInfo card;

  const TaquillaScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modo Taquilla')),
      body: Center(
        child: Text('Taquilla para tarjeta: ${card.id}'),
      ),
    );
  }
}
