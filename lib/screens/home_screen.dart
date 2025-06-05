import 'package:flutter/material.dart';
import 'package:panes_app/screens/clientes_screen.dart';
import 'package:panes_app/screens/panes/panes_menu_screen.dart';
import 'package:panes_app/screens/pedidos/pedido_cliente_screen.dart';
import 'package:panes_app/widgets/menu_button.dart';

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
              MenuButton(
                icon: Icons.bakery_dining,
                label: 'Gestión de Panes',
                onTap: () => _navigateTo(context, const PanesMenuScreen()),
              ),
              MenuButton(
                icon: Icons.store,
                label: 'Clientes',
                onTap: () => _navigateTo(context, const ClientesScreen()),
              ),
              MenuButton(
                icon: Icons.menu_book,
                label: 'Pedidos',
                onTap: () => _navigateTo(context, const PedidoClienteScreen()),
              ),
              MenuButton(
                icon: Icons.calculate,
                label: 'Calculadora',
                onTap: () {
                  // Aquí puedes implementar la navegación o lógica que desees
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
