import 'package:flutter/material.dart';
import '../models/receta_tipo_pan_model.dart';
import '../db/db_provider.dart';

class RecetaTipoProvider with ChangeNotifier {
  List<RecetaTipoPanModel> recetas = [];

  Future<void> loadRecetaForTipo(int idTipoPan) async {
    final db = await DBProvider.db.database;
    final res = await db.rawQuery(
      '''
      SELECT r.*, i.nombre AS ingredienteNombre, u.tipo AS unidadNombre
      FROM receta_tipo_pan r
      JOIN ingredientes_catalogo i ON r.id_ingrediente = i.id
      JOIN unidades u ON r.id_unidad = u.id
      WHERE r.id_tipo_pan = ?
    ''',
      [idTipoPan],
    );

    recetas = res.map((e) => RecetaTipoPanModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> insertReceta(RecetaTipoPanModel receta) async {
    final db = await DBProvider.db.database;
    await db.insert('receta_tipo_pan', receta.toMap());
    await loadRecetaForTipo(receta.idTipoPan);
  }

  Future<void> deleteReceta(int id, int idTipoPan) async {
    final db = await DBProvider.db.database;
    await db.delete('receta_tipo_pan', where: 'id = ?', whereArgs: [id]);
    await loadRecetaForTipo(idTipoPan);
  }
}
