import 'package:flutter/material.dart';
import 'package:panes_app/screens/panes/ingredientes_screen.dart';
import 'package:panes_app/screens/panes/tipos_pan_screen.dart';
import 'package:panes_app/screens/panes/unidades_screen.dart';
import 'package:panes_app/screens/panes/view_bread_screen.dart';

class PanesMenuScreen extends StatelessWidget {
  const PanesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F2),
      appBar: AppBar(
        title: const Text('Gestión de Panes'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PanaPan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4D3C2B),
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuButton(
              context,
              icon: Icons.bakery_dining,
              label: 'Panes',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VerPanesScreen()),
                );
              },
            ),
            _buildMenuButton(
              context,
              icon: Icons.category,
              label: 'Tipos de Pan',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TiposPanScreen()),
                );
              },
            ),
            _buildMenuButton(
              context,
              icon: Icons.straighten,
              label: 'Unidades',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UnidadesScreen()),
                );
              },
            ),
            _buildMenuButton(
              context,
              icon: Icons.kitchen,
              label: 'Ingredientes',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IngredientesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      child: Material(
        color: const Color(0xFFF2EDE7),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Icon(icon, size: 28, color: const Color(0xFF4D3C2B)),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF4D3C2B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
