import 'package:flutter/material.dart';
import '../../core/models/game_config.dart';

class OperadorScreen extends StatelessWidget {
  final GameConfig config;

  const OperadorScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Juego: ${config.juegoNombre ?? 'Sin juego'}'),
      ),
      body: Center(
        child: Text(
          'Precio: ${config.juegoPrecio ?? 0}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
