import 'package:flutter/material.dart';
import '../models/tipo_pan_model.dart';
import '../db/db_provider.dart';

class TipoPanProvider with ChangeNotifier {
  List<TipoPanModel> tipos = [];

  Future<void> loadTipos() async {
    final db = await DBProvider.db.database;
    final res = await db.query('tipos');
    tipos = res.map((e) => TipoPanModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> insertTipo(TipoPanModel tipo) async {
    final db = await DBProvider.db.database;
    await db.insert('tipos', tipo.toMap());
    await loadTipos();
  }

  Future<void> updateTipo(TipoPanModel tipo) async {
    final db = await DBProvider.db.database;
    await db.update(
      'tipos',
      tipo.toMap(),
      where: 'id = ?',
      whereArgs: [tipo.id],
    );
    await loadTipos();
  }

  Future<void> deleteTipo(int id) async {
    final db = await DBProvider.db.database;
    await db.delete('tipos', where: 'id = ?', whereArgs: [id]);
    await loadTipos();
  }
}
