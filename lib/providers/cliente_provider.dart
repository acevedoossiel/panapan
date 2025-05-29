import 'package:flutter/material.dart';
import '../models/cliente_model.dart';
import '../db/db_provider.dart';

class ClienteProvider with ChangeNotifier {
  List<ClienteModel> clientes = [];

  Future<void> loadClientes() async {
    final db = await DBProvider.db.database;
    final res = await db.query('clientes');
    clientes = res.map((e) => ClienteModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> insertCliente(ClienteModel cliente) async {
    final db = await DBProvider.db.database;
    await db.insert('clientes', cliente.toMap());
    await loadClientes();
  }

  Future<void> updateCliente(ClienteModel cliente) async {
    final db = await DBProvider.db.database;
    await db.update(
      'clientes',
      cliente.toMap(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
    await loadClientes();
  }

  Future<void> deleteCliente(int id) async {
    final db = await DBProvider.db.database;
    await db.delete('clientes', where: 'id = ?', whereArgs: [id]);
    await loadClientes();
  }
}
