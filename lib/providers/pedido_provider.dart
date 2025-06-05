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

  Future<List<PedidoClienteModel>> loadPedidosByDate(DateTime fecha) async {
    final db = await DBProvider.db.database;

    // Convertimos la fecha a formato 'YYYY-MM-DD'
    final fechaFormateada =
        '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

    final res = await db.rawQuery(
      '''
    SELECT p.id, p.id_cliente, p.fecha, p.total, c.nombre AS nombre_cliente
    FROM pedido_cliente p
    JOIN clientes c ON p.id_cliente = c.id
    WHERE DATE(p.fecha) = ?
    ORDER BY p.fecha DESC
  ''',
      [fechaFormateada],
    );

    return res.map((e) => PedidoClienteModel.fromMap(e)).toList();
  }
}
