import 'package:flutter/material.dart';
import '../models/pedido_cliente_model.dart';
import '../db/db_provider.dart';

class PedidoProvider with ChangeNotifier {
  List<PedidoClienteModel> pedidos = [];

  Future<void> loadPedidos() async {
    final db = await DBProvider.db.database;
    final res = await db.rawQuery('''
    SELECT p.id, p.id_cliente, p.fecha, p.total, c.nombre AS nombre_cliente
    FROM pedido_cliente p
    JOIN clientes c ON p.id_cliente = c.id
    ORDER BY p.fecha DESC
  ''');
    pedidos = res.map((e) => PedidoClienteModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> loadPedidosConClientes() async {
    final db = await DBProvider.db.database;
    final res = await db.rawQuery('''
    SELECT p.id, p.id_cliente, p.fecha, p.total, c.nombre AS nombre_cliente
    FROM pedido_cliente p
    JOIN clientes c ON p.id_cliente = c.id
    ORDER BY p.fecha DESC
  ''');
    pedidos = res.map((e) => PedidoClienteModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<int> insertPedido(PedidoClienteModel pedido) async {
    final db = await DBProvider.db.database;
    final id = await db.insert('pedido_cliente', pedido.toMap());
    await loadPedidos();
    return id;
  }
}
