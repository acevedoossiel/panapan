import 'package:flutter/material.dart';
import '../db/db_provider.dart';
import '../models/tipo_model.dart';

class TipoProvider extends ChangeNotifier {
  List<TipoModel> tipos = [];

  Future<void> loadTipos() async {
    print("cargando tipos de nuevo");
    final db = await DBProvider.db.database;
    final res = await db.query('tipos');
    tipos = res.map((e) => TipoModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> insertTipo(String tipoNombre) async {
    print("ENtrando a crear pan:");
    final db = await DBProvider.db.database;
    await db.insert('tipos', {'tipo': tipoNombre});
    await loadTipos();
  }

  Future<void> updateTipo(int id, String nuevoNombre) async {
    final db = await DBProvider.db.database;
    await db.update(
      'tipos',
      {'tipo': nuevoNombre},
      where: 'id = ?',
      whereArgs: [id],
    );
    await loadTipos();
  }

  Future<void> deleteTipo(int id) async {
    final db = await DBProvider.db.database;
    await db.delete('tipos', where: 'id = ?', whereArgs: [id]);
    await loadTipos();
  }
}
