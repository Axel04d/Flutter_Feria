import 'package:flutter/material.dart';
import '../../core/models/card_info.dart';
import 'consultar_saldo_screen.dart';
import 'recargar_screen.dart';
import 'devolver_saldo_screen.dart';
import 'crear_cliente_screen.dart';

class TaquillaScreen extends StatelessWidget {
  final CardInfo card; // Tarjeta TAQUILLA (type = 1, id = taquillaId)

  const TaquillaScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final taquillaId = card.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Taquilla',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderCard(taquillaId),
            const SizedBox(height: 24),
            _buildActionButton(
              context,
              icon: Icons.search,
              color: Colors.blueAccent,
              text: 'Consultar saldo',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ConsultarSaldoScreen(taquillaId: taquillaId),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              icon: Icons.add_circle_outline,
              color: Colors.green,
              text: 'Recargar saldo',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecargarScreen(taquillaId: taquillaId),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              icon: Icons.money_off_csred_rounded,
              color: Colors.redAccent,
              text: 'Devolver saldo',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DevolverSaldoScreen(taquillaId: taquillaId),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              icon: Icons.credit_card,
              color: Colors.deepPurple,
              text: 'Crear tarjeta cliente',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CrearClienteScreen(taquillaId: taquillaId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(int taquillaId) {
    return Container(
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
        children: [
          Text(
            'Taquilla #${taquillaId.toString().padLeft(3, '0')}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Modo taquilla activo',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          const Icon(Icons.point_of_sale, size: 40, color: Colors.blueGrey),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
