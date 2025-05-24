import 'package:flutter/material.dart';
import '../db/db_provider.dart';
import '../models/ingredient_model.dart';

class IngredientProvider extends ChangeNotifier {
  List<IngredientModel> ingredientes = [];

  Future<void> loadIngredientes() async {
    final db = await DBProvider.db.database;
    final res = await db.rawQuery('''
      SELECT ingredientes_catalogo.*, unidades.tipo AS unidadNombre
      FROM ingredientes_catalogo
      LEFT JOIN unidades ON ingredientes_catalogo.id_unidad = unidades.id
    ''');
    ingredientes = res.map((e) => IngredientModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> insertIngrediente(IngredientModel i) async {
    final db = await DBProvider.db.database;
    await db.insert('ingredientes_catalogo', i.toMap());
    await loadIngredientes();
  }

  Future<void> updateIngrediente(IngredientModel i) async {
    final db = await DBProvider.db.database;
    await db.update(
      'ingredientes_catalogo',
      i.toMap(),
      where: 'id = ?',
      whereArgs: [i.id],
    );
    await loadIngredientes();
  }

  Future<void> deleteIngrediente(int id) async {
    final db = await DBProvider.db.database;
    await db.delete('ingredientes_catalogo', where: 'id = ?', whereArgs: [id]);
    await loadIngredientes();
  }
}
