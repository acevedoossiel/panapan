import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:panes_app/db/db_provider.dart';
import 'package:panes_app/models/receta_model.dart';
import 'package:panes_app/providers/receta_provider.dart';

void main() {
  late RecetaProvider recetaProvider;

  setUpAll(() async {
    sqfliteFfiInit();
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    DBProvider.overrideDatabase = db;

    await db.execute('''
      CREATE TABLE unidades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE ingredientes_catalogo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        cantidad REAL,
        id_unidad INTEGER,
        FOREIGN KEY (id_unidad) REFERENCES unidades(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE receta_ingredientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_pan INTEGER,
        id_ingrediente INTEGER,
        cantidad REAL,
        FOREIGN KEY (id_ingrediente) REFERENCES ingredientes_catalogo(id)
      );
    ''');
  });

  setUp(() async {
    recetaProvider = RecetaProvider();
    final db = await DBProvider.db.database;
    await db.delete('receta_ingredientes');
    await db.delete('ingredientes_catalogo');
    await db.delete('unidades');
  });

  test('inserta una receta correctamente', () async {
    final db = await DBProvider.db.database;

    final unidadId = await db.insert('unidades', {'tipo': 'kg'});
    final ingredienteId = await db.insert('ingredientes_catalogo', {
      'nombre': 'Azúcar',
      'cantidad': 500.0,
      'id_unidad': unidadId,
    });

    final receta = RecetaIngredienteModel(
      idPan: 1,
      idIngrediente: ingredienteId,
      cantidad: 100.0,
    );

    await recetaProvider.insertReceta(receta);

    expect(recetaProvider.recetas.length, 1);
    expect(recetaProvider.recetas.first.ingredienteNombre, 'Azúcar');
    expect(recetaProvider.recetas.first.unidadNombre, 'kg');
  });

  test('elimina una receta correctamente', () async {
    final db = await DBProvider.db.database;

    final unidadId = await db.insert('unidades', {'tipo': 'g'});
    final ingredienteId = await db.insert('ingredientes_catalogo', {
      'nombre': 'Harina',
      'cantidad': 1000.0,
      'id_unidad': unidadId,
    });

    final receta = RecetaIngredienteModel(
      idPan: 2,
      idIngrediente: ingredienteId,
      cantidad: 300.0,
    );

    await recetaProvider.insertReceta(receta);
    final idToDelete = recetaProvider.recetas.first.id!;
    await recetaProvider.deleteReceta(idToDelete, 2);

    expect(recetaProvider.recetas.length, 0);
  });
}
