import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import '../../core/models/game_config.dart';
import '../../core/nfc/nfc_reader.dart';
import '../../core/models/card_info.dart';
import '../admin/configurar_juego_screen.dart';
import '../taquilla/taquilla_screen.dart';
import '../operador/operador_screen.dart';
import '../reader/reader_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  GameConfig? _config;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final db = await AppDatabase.instance;
    final config = await db.configDao.getCurrentGameConfig();
    setState(() {
      _config = config;
      _loading = false;
    });

    if (config.terminalTipo == 'juego' &&
        config.juegoNombre != null &&
        config.juegoPrecio != null) {
      // Ir directo al modo operador (juego configurado)
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OperadorScreen(config: config),
        ),
      );
    }
  }

  void _onTagRead(CardInfo card) {
    // Dependiendo del type, navegamos
    switch (card.type) {
      case 9: // Admin
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ConfigurarJuegoScreen(),
          ),
        );
        break;
      case 1: // Taquilla
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaquillaScreen(card: card),
          ),
        );
        break;
      case 3: // Cliente
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReaderScreen(card: card),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarjeta desconocida')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: NFCReader(
        onTagRead: _onTagRead,
        child: Center(
          child: Text(
            'Aproxime una tarjeta para comenzar',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
