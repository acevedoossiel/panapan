import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetita/models/bread_model.dart';
import 'package:recetita/providers/bread_providers.dart';

class BreadDetails extends StatefulWidget {
  final BreadModel breadData;

  const BreadDetails({super.key, required this.breadData});

  @override
  BreadDetailsState createState() => BreadDetailsState();
}

class BreadDetailsState extends State<BreadDetails> {
  bool isFavorite = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isFavorite = Provider.of<BreadProvider>(
      context,
      listen: false,
    ).favoriteBreads.contains(widget.breadData);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[700],
        title: Text(
          widget.breadData.name,
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Provider.of<BreadProvider>(
                context,
                listen: false,
              ).toggleFavoriteStatus(widget.breadData);
              setState(() => isFavorite = !isFavorite);
            },
            icon: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
                key: ValueKey<bool>(isFavorite),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'bread-image-${widget.breadData.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  widget.breadData.imageLink,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.breadData.name,
                  style: TextStyle(
                    fontSize: 24,
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text("Panadero: ${widget.breadData.baker}"),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.category_outlined, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text("Tipo: ${widget.breadData.type}"),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Precio: \$${widget.breadData.price.toStringAsFixed(2)} MXN",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                Divider(height: 30, thickness: 2),
                Text(
                  "Descripción:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  widget.breadData.description,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 30),
                Consumer<BreadProvider>(
                  builder: (context, provider, _) {
                    final isInCart = provider.cartBreads.contains(
                      widget.breadData,
                    );
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          provider.toggleCartStatus(widget.breadData);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isInCart
                                    ? "Quitado de la canasta"
                                    : "¡Pan agregado a la canasta!",
                              ),
                              backgroundColor:
                                  isInCart ? Colors.orange : Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: Icon(
                          isInCart
                              ? Icons.remove_shopping_cart
                              : Icons.add_shopping_cart,
                        ),
                        label: Text(
                          isInCart
                              ? "Quitar de la canasta"
                              : "Agregar a la canasta",
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isInCart ? Colors.orange[400] : Colors.amber[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
