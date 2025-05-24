import 'package:flutter/material.dart';
import '../db/db_provider.dart';
import '../models/receta_model.dart';

class RecetaProvider extends ChangeNotifier {
  List<RecetaIngredienteModel> recetas = [];

  Future<void> loadRecetaForPan(int idPan) async {
    final db = await DBProvider.db.database;
    final res = await db.rawQuery(
      '''
      SELECT r.*, i.nombre AS ingredienteNombre, u.tipo AS unidadNombre
      FROM receta_ingredientes r
      LEFT JOIN ingredientes_catalogo i ON r.id_ingrediente = i.id
      LEFT JOIN unidades u ON i.id_unidad = u.id
      WHERE r.id_pan = ?

    ''',
      [idPan],
    );

    recetas = res.map((e) => RecetaIngredienteModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> insertReceta(RecetaIngredienteModel r) async {
    final db = await DBProvider.db.database;
    await db.insert('receta_ingredientes', r.toMap());
    await loadRecetaForPan(r.idPan);
  }

  Future<void> deleteReceta(int id, int idPan) async {
    final db = await DBProvider.db.database;
    await db.delete('receta_ingredientes', where: 'id = ?', whereArgs: [id]);
    await loadRecetaForPan(idPan);
  }
}
