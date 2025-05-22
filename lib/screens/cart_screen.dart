import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetita/models/bread_model.dart';
import 'package:recetita/providers/bread_providers.dart';
import 'package:recetita/screens/bread_details.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Carrito de Panes'),
        backgroundColor: Colors.amber[700],
      ),
      body: Consumer<BreadProvider>(
        builder: (context, breadProvider, child) {
          final cart = breadProvider.cartBreads;

          return cart.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_basket_outlined,
                      size: 50,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Tu canasta está vacía",
                      style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "¡Agrega algunos deliciosos panes!",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        final bread = cart[index];
                        return CartItemCard(bread: bread);
                      },
                    ),
                  ),
                  // Total y botón de compra
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      border: Border(
                        top: BorderSide(color: Colors.amber[100]!),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total:",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "\$${breadProvider.getCartTotal().toStringAsFixed(2)} MXN",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            breadProvider.clearCart();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('¡Pedido realizado con éxito!'),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: Icon(Icons.shopping_bag),
                          label: Text("Confirmar pedido"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[700],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
        },
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final BreadModel bread;
  const CartItemCard({super.key, required this.bread});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BreadProvider>(context);
    final qty = provider.getCartQuantity(bread);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          contentPadding: EdgeInsets.all(8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              bread.imageLink,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            bread.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tipo: ${bread.type}"),
              SizedBox(height: 4),
              Text("Precio: \$${bread.price.toStringAsFixed(2)} MXN"),
              Text(
                "Subtotal: \$${(bread.price * qty).toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove, color: Colors.red),
                onPressed: () => provider.decreaseQuantity(bread),
                tooltip: "Quitar uno",
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$qty",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.amber[900],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: Colors.green),
                onPressed: () => provider.increaseQuantity(bread),
                tooltip: "Agregar uno",
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BreadDetails(breadData: bread)),
            );
          },
        ),
      ),
    );
  }
}
