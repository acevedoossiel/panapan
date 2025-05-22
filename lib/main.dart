import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetita/providers/bread_providers.dart';
import 'package:recetita/screens/favorites_screen.dart';
import 'package:recetita/screens/home_screen.dart';
import 'package:recetita/screens/cart_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => BreadProvider())],
      child: MaterialApp(
        title: 'Panadería Artesanal',
        theme: ThemeData(
          fontFamily: 'Montserrat',
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.amber,
            primary: Colors.amber[700],
          ),
        ),
        home: const PanaderiaApp(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class PanaderiaApp extends StatelessWidget {
  const PanaderiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber[700],
          title: const Text(
            "Panadería Artesanal",
            style: TextStyle(color: Colors.white),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[300],
            tabs: const <Widget>[
              Tab(icon: Icon(Icons.home), text: 'Inicio'),
              Tab(icon: Icon(Icons.favorite), text: 'Favoritos'),
              Tab(icon: Icon(Icons.shopping_cart), text: 'Canasta'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [HomeScreen(), FavoritesScreen(), CartScreen()],
        ),
      ),
    );
  }
}
