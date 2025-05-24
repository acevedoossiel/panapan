import 'package:flutter/material.dart';
import 'package:panes_app/providers/ingredient_provider.dart';
import 'package:panes_app/providers/receta_provider.dart';
import 'package:panes_app/providers/tipo_provider.dart';
import 'package:panes_app/providers/unidad_provider.dart';
import 'package:provider/provider.dart';
import 'providers/bread_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BreadProvider()),
        ChangeNotifierProvider(create: (_) => TipoProvider()),
        ChangeNotifierProvider(create: (_) => UnidadProvider()),
        ChangeNotifierProvider(create: (_) => IngredientProvider()),
        ChangeNotifierProvider(create: (_) => RecetaProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Panapan', home: HomeScreen());
  }
}
