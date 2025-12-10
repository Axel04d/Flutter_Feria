import 'package:flutter/material.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AtraccionesMenesesApp());
}

class AtraccionesMenesesApp extends StatelessWidget {
  const AtraccionesMenesesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atracciones Meneses',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
