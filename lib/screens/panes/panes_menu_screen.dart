import 'package:flutter/material.dart';
import 'package:panes_app/screens/panes/ingredientes_screen.dart';
import 'package:panes_app/screens/panes/tipos_pan_screen.dart';
import 'package:panes_app/screens/panes/unidades_screen.dart';
import 'package:panes_app/screens/panes/view_bread_screen.dart';
import 'package:panes_app/widgets/menu_button.dart';

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
            MenuButton(
              icon: Icons.bakery_dining,
              label: 'Panes',
              onTap: () => _navigateTo(context, const VerPanesScreen()),
            ),
            MenuButton(
              icon: Icons.category,
              label: 'Tipos de Pan',
              onTap: () => _navigateTo(context, const TiposPanScreen()),
            ),
            MenuButton(
              icon: Icons.straighten,
              label: 'Unidades',
              onTap: () => _navigateTo(context, const UnidadesScreen()),
            ),
            MenuButton(
              icon: Icons.kitchen,
              label: 'Ingredientes',
              onTap: () => _navigateTo(context, const IngredientesScreen()),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
