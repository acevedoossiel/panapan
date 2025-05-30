import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:panes_app/db/db_provider.dart';
import 'package:panes_app/models/receta_tipo_pan_model.dart';
import 'package:panes_app/providers/receta_tipo_provider.dart';

void main() {
  late RecetaTipoProvider recetaTipoProvider;

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
      CREATE TABLE receta_tipo_pan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_tipo_pan INTEGER,
        id_ingrediente INTEGER,
        cantidad REAL,
        id_unidad INTEGER,
        FOREIGN KEY (id_ingrediente) REFERENCES ingredientes_catalogo(id),
        FOREIGN KEY (id_unidad) REFERENCES unidades(id)
      );
    ''');
  });

  setUp(() async {
    recetaTipoProvider = RecetaTipoProvider();
    final db = await DBProvider.db.database;
    await db.delete('receta_tipo_pan');
    await db.delete('ingredientes_catalogo');
    await db.delete('unidades');
  });

  test('inserta una receta por tipo correctamente', () async {
    final db = await DBProvider.db.database;

    final unidadId = await db.insert('unidades', {'tipo': 'ml'});
    final ingredienteId = await db.insert('ingredientes_catalogo', {
      'nombre': 'Leche',
      'cantidad': 1000.0,
      'id_unidad': unidadId,
    });

    final receta = RecetaTipoPanModel(
      idTipoPan: 1,
      idIngrediente: ingredienteId,
      cantidad: 250.0,
      idUnidad: unidadId,
    );

    await recetaTipoProvider.insertReceta(receta);

    expect(recetaTipoProvider.recetas.length, 1);
    expect(recetaTipoProvider.recetas.first.ingredienteNombre, 'Leche');
    expect(recetaTipoProvider.recetas.first.unidadNombre, 'ml');
  });

  test('elimina una receta por tipo correctamente', () async {
    final db = await DBProvider.db.database;

    final unidadId = await db.insert('unidades', {'tipo': 'gr'});
    final ingredienteId = await db.insert('ingredientes_catalogo', {
      'nombre': 'Mantequilla',
      'cantidad': 500.0,
      'id_unidad': unidadId,
    });

    final receta = RecetaTipoPanModel(
      idTipoPan: 2,
      idIngrediente: ingredienteId,
      cantidad: 100.0,
      idUnidad: unidadId,
    );

    await recetaTipoProvider.insertReceta(receta);
    final idToDelete = recetaTipoProvider.recetas.first.id!;
    await recetaTipoProvider.deleteReceta(idToDelete, 2);

    expect(recetaTipoProvider.recetas.length, 0);
  });
}
