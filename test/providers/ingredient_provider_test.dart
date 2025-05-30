import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:panes_app/db/db_provider.dart';
import 'package:panes_app/models/ingredient_model.dart';
import 'package:panes_app/providers/ingredient_provider.dart';

void main() {
  late IngredientProvider ingredientProvider;

  setUpAll(() async {
    sqfliteFfiInit();
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    DBProvider.overrideDatabase = db;

    // Crear tabla de unidades (por la clave foránea y el LEFT JOIN)
    await db.execute('''
      CREATE TABLE unidades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT
      );
    ''');

    // Crear tabla de ingredientes
    await db.execute('''
      CREATE TABLE ingredientes_catalogo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        cantidad REAL,
        id_unidad INTEGER,
        FOREIGN KEY (id_unidad) REFERENCES unidades(id)
      );
    ''');

    // Insertar una unidad para pruebas
    await db.insert('unidades', {'tipo': 'gramos'});
  });

  setUp(() async {
    ingredientProvider = IngredientProvider();
    final db = await DBProvider.db.database;
    await db.delete('ingredientes_catalogo');
  });

  test('inserta un ingrediente correctamente', () async {
    final ingrediente = IngredientModel(
      nombre: 'Harina',
      cantidad: 2.5,
      idUnidad: 1,
    );

    await ingredientProvider.insertIngrediente(ingrediente);

    expect(ingredientProvider.ingredientes.length, 1);
    expect(ingredientProvider.ingredientes.first.nombre, 'Harina');
    expect(ingredientProvider.ingredientes.first.cantidad, 2.5);
    expect(ingredientProvider.ingredientes.first.unidadNombre, 'gramos');
  });

  test('actualiza un ingrediente correctamente', () async {
    final ingrediente = IngredientModel(
      nombre: 'Azúcar',
      cantidad: 1.0,
      idUnidad: 1,
    );

    await ingredientProvider.insertIngrediente(ingrediente);

    final actualizado = IngredientModel(
      id: ingredientProvider.ingredientes.first.id,
      nombre: 'Azúcar refinada',
      cantidad: 1.2,
      idUnidad: 1,
    );

    await ingredientProvider.updateIngrediente(actualizado);

    expect(ingredientProvider.ingredientes.first.nombre, 'Azúcar refinada');
    expect(ingredientProvider.ingredientes.first.cantidad, 1.2);
  });

  test('elimina un ingrediente correctamente', () async {
    final ingrediente = IngredientModel(
      nombre: 'Manteca',
      cantidad: 0.5,
      idUnidad: 1,
    );

    await ingredientProvider.insertIngrediente(ingrediente);
    final id = ingredientProvider.ingredientes.first.id!;
    await ingredientProvider.deleteIngrediente(id);

    expect(ingredientProvider.ingredientes.length, 0);
  });
}
