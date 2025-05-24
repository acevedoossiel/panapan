import 'package:flutter/material.dart';
import '../models/bread_model.dart';
import '../db/db_provider.dart';

class BreadProvider extends ChangeNotifier {
  List<BreadModel> _breads = [];

  List<BreadModel> get breads => _breads;

  Future<void> loadBreads() async {
    final db = await DBProvider.db.database;
    final res = await db.rawQuery('''
    SELECT panes.id, panes.nombre, panes.id_tipo, panes.precio, tipos.tipo AS tipoNombre
    FROM panes
    LEFT JOIN tipos ON panes.id_tipo = tipos.id
  ''');
    _breads = res.map((e) => BreadModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addBread(BreadModel bread) async {
    final db = await DBProvider.db.database;
    await db.insert('panes', bread.toMap());
    await loadBreads(); // << Esto recarga todo con JOIN y tipoNombre
  }

  Future<void> deleteBread(int id) async {
    final db = await DBProvider.db.database;
    await db.delete('panes', where: 'id = ?', whereArgs: [id]);
    await loadBreads();
  }

  Future<void> updateBread(BreadModel pan) async {
    final db = await DBProvider.db.database;
    await db.update('panes', pan.toMap(), where: 'id = ?', whereArgs: [pan.id]);
    await loadBreads(); // << También lo vuelve a cargar con JOIN
  }
}
