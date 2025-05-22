import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetita/providers/bread_providers.dart';
import 'package:recetita/screens/bread_details.dart';
import '../models/bread_model.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<BreadProvider>(
        builder: (context, breadProvider, child) {
          final favoriteBreads = breadProvider.favoriteBreads;

          return favoriteBreads.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 50, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No hay panes favoritos",
                      style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "¡Agrega tus panes favoritos!",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: favoriteBreads.length,
                itemBuilder: (context, index) {
                  final bread = favoriteBreads[index];
                  return FavoriteBreadCard(bread: bread);
                },
              );
        },
      ),
    );
  }
}

class FavoriteBreadCard extends StatelessWidget {
  final BreadModel bread;
  const FavoriteBreadCard({super.key, required this.bread});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BreadDetails(breadData: bread),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  bread.imageLink,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bread.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(bread.type, style: TextStyle(color: Colors.grey[600])),
                    SizedBox(height: 8),
                    Text(
                      "\$${bread.price.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () {
                  Provider.of<BreadProvider>(
                    context,
                    listen: false,
                  ).toggleFavoriteStatus(bread);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
