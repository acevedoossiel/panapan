import 'package:flutter/material.dart';
import '../db/db_provider.dart';
import '../models/unidad_model.dart';

class UnidadProvider extends ChangeNotifier {
  List<UnidadModel> unidades = [];

  Future<void> loadUnidades() async {
    final db = await DBProvider.db.database;
    final res = await db.query('unidades');
    unidades = res.map((e) => UnidadModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> insertUnidad(String tipo) async {
    final db = await DBProvider.db.database;
    await db.insert('unidades', {'tipo': tipo});
    await loadUnidades();
  }

  Future<void> updateUnidad(int id, String nuevoTipo) async {
    final db = await DBProvider.db.database;
    await db.update(
      'unidades',
      {'tipo': nuevoTipo},
      where: 'id = ?',
      whereArgs: [id],
    );
    await loadUnidades();
  }

  Future<void> deleteUnidad(int id) async {
    final db = await DBProvider.db.database;
    await db.delete('unidades', where: 'id = ?', whereArgs: [id]);
    await loadUnidades();
  }
}
