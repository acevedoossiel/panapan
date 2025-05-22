import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Widget;
import 'package:recetita/models/bread_model.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class BreadProvider extends ChangeNotifier {
  bool isLoading = false;

  List<BreadModel> breads = [];
  List<BreadModel> favoriteBreads = [];
  List<BreadModel> cartBreads = [];
  Map<int, int> cartQuantities = {};

  String getBaseUrl() {
    if (kIsWeb) {
      return 'http://0.0.0.0:12345';
    } else if (Platform.isAndroid) {
      return 'http://0.0.0.0:12345';
    } else if (Platform.isIOS) {
      return 'http://localhost:12345';
    } else {
      return 'http://192.168.1.75:12345';
    }
  }

  Future<void> fetchBreads() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('${getBaseUrl()}/breads');

    print("Fetching breads");
    try {
      final response = await http.get(url);

      print("Response status ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("Clave 'breads' existe: ${data.containsKey('breads')}");
        print("Contenido de 'breads': ${data['breads']}");

        breads = List<BreadModel>.from(
          data['breads'].map((bread) => BreadModel.fromJSON(bread)),
        );
      } else {
        breads = [];
      }
    } catch (e) {
      print("Error in request: $e");
      breads = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearCart() {
    cartBreads.clear();
    cartQuantities.clear();
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(BreadModel bread) async {
    final isFavorite = favoriteBreads.contains(bread);

    try {
      if (isFavorite) {
        favoriteBreads.remove(bread);
      } else {
        favoriteBreads.add(bread);
      }
      print("Favorite status toggled: ${bread.name}");
      print("Total favorites: ${favoriteBreads.length}");

      notifyListeners();
    } catch (e) {
      print("Error updating favorite breads: $e");
      notifyListeners();
    }
  }

  void toggleCartStatus(BreadModel bread) {
    if (cartBreads.contains(bread)) {
      cartBreads.remove(bread);
      cartQuantities.remove(bread.id);
    } else {
      cartBreads.add(bread);
      cartQuantities[bread.id] = 1; // Inicia con cantidad 1
    }
    notifyListeners();
  }

  void increaseQuantity(BreadModel bread) {
    if (cartQuantities.containsKey(bread.id)) {
      cartQuantities[bread.id] = cartQuantities[bread.id]! + 1;
      notifyListeners();
    }
  }

  void decreaseQuantity(BreadModel bread) {
    if (cartQuantities.containsKey(bread.id)) {
      final current = cartQuantities[bread.id]!;
      if (current > 1) {
        cartQuantities[bread.id] = current - 1;
      } else {
        cartBreads.remove(bread);
        cartQuantities.remove(bread.id);
      }
      notifyListeners();
    }
  }

  int getCartQuantity(BreadModel bread) {
    return cartQuantities[bread.id] ?? 1;
  }

  double getCartTotal() {
    double total = 0.0;
    for (var bread in cartBreads) {
      final qty = cartQuantities[bread.id] ?? 1;
      total += bread.price * qty;
    }
    return total;
  }

  Future<bool> saveBread(BreadModel bread) async {
    try {
      print('Saving bread: ${bread.name}');
      breads.add(bread);
      print('Total breads now: ${breads.length}');

      notifyListeners();
      return true;
    } catch (e) {
      print('Error saving bread: $e');
      return false;
    }
  }

  // Método adicional para manejo de pedidos
  Future<bool> placeOrder() async {
    if (cartBreads.isEmpty) return false;

    try {
      // Simular envío del pedido
      await Future.delayed(Duration(seconds: 2));

      // Limpiar carrito después de orden exitosa
      clearCart();
      return true;
    } catch (e) {
      print('Error placing order: $e');
      return false;
    }
  }
}
