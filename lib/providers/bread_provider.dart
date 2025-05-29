import 'package:flutter/material.dart';
import '../models/bread_model.dart';
import '../db/db_provider.dart';

class BreadProvider extends ChangeNotifier {
  List<PanModel> _breads = [];

  List<PanModel> get breads => _breads;

  Future<void> loadBreads() async {
    final db = await DBProvider.db.database;
    final res = await db.query('panes');
    _breads = res.map((e) => PanModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addBread(PanModel bread) async {
    final db = await DBProvider.db.database;
    final id = await db.insert('panes', bread.toMap());
    print("Nuevo pan insertado con ID: $id");
    await loadBreads();
  }

  Future<void> deleteBread(int id) async {
    final db = await DBProvider.db.database;
    await db.delete('panes', where: 'id = ?', whereArgs: [id]);
    await loadBreads();
  }

  Future<void> updateBread(PanModel pan) async {
    final db = await DBProvider.db.database;
    await db.update('panes', pan.toMap(), where: 'id = ?', whereArgs: [pan.id]);
    await loadBreads();
  }
}
