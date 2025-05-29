import 'package:flutter/material.dart';
import 'package:panes_app/providers/cliente_provider.dart';
import 'package:panes_app/providers/ingredient_provider.dart';
import 'package:panes_app/providers/pedido_detalle_provider.dart';
import 'package:panes_app/providers/pedido_provider.dart';
import 'package:panes_app/providers/receta_provider.dart';
import 'package:panes_app/providers/unidad_provider.dart';
import 'package:provider/provider.dart';
import 'providers/bread_provider.dart';
import 'providers/tipo_pan_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BreadProvider()),
        ChangeNotifierProvider(create: (_) => TipoPanProvider()),
        ChangeNotifierProvider(create: (_) => UnidadProvider()),
        ChangeNotifierProvider(create: (_) => IngredientProvider()),
        ChangeNotifierProvider(create: (_) => RecetaProvider()),
        ChangeNotifierProvider(create: (_) => ClienteProvider()),
        ChangeNotifierProvider(create: (_) => PedidoProvider()),
        ChangeNotifierProvider(create: (_) => PedidoDetalleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Panapan', home: HomeScreen());
  }
}
