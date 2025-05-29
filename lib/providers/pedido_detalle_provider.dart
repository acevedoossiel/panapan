import 'package:flutter/material.dart';
import '../models/pedido_detalle_model.dart';
import '../db/db_provider.dart';

class PedidoDetalleProvider with ChangeNotifier {
  List<PedidoDetalleModel> detalles = [];

  Future<void> loadDetallesForPedido(int idPedido) async {
    final db = await DBProvider.db.database;
    final res = await db.rawQuery(
      '''
      SELECT d.*, t.tipo AS tipoPanNombre
      FROM pedido_cliente_detalle d
      JOIN tipos t ON d.id_tipo_pan = t.id
      WHERE d.id_pedido_cliente = ?
    ''',
      [idPedido],
    );

    detalles = res.map((e) => PedidoDetalleModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> insertDetalle(
    int idPedidoCliente,
    int idTipoPan,
    int cantidad,
  ) async {
    final db = await DBProvider.db.database;
    await db.insert('pedido_cliente_detalle', {
      'id_pedido_cliente': idPedidoCliente,
      'id_tipo_pan': idTipoPan,
      'cantidad': cantidad,
    });
  }
}
