import 'package:flutter/material.dart';
import 'package:panes_app/screens/clientes_screen.dart';
import 'package:panes_app/screens/panes/panes_menu_screen.dart';
import 'package:panes_app/screens/pedidos/pedido_cliente_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PanaPan',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4D3C2B),
                ),
              ),
              const SizedBox(height: 32),
              _buildMenuButton(
                context,
                icon: Icons.bakery_dining,
                label: 'Gestión de Panes',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PanesMenuScreen()),
                  );
                },
              ),
              _buildMenuButton(
                context,
                icon: Icons.store,
                label: 'Clientes',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ClientesScreen()),
                  );
                },
              ),
              _buildMenuButton(
                context,
                icon: Icons.menu_book,
                label: 'Pedidos',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PedidoClienteScreen(),
                    ),
                  );
                },
              ),
              _buildMenuButton(
                context,
                icon: Icons.calculate,
                label: 'Calculadora',
                onTap: () {
                  // TODO: Navegar a CalculadoraScreen
                },
              ),
            ],
          ),
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
