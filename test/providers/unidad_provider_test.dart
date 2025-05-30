import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:panes_app/db/db_provider.dart';
import 'package:panes_app/providers/unidad_provider.dart';

void main() {
  late UnidadProvider unidadProvider;

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
  });

  setUp(() async {
    unidadProvider = UnidadProvider();
    final db = await DBProvider.db.database;
    await db.delete('unidades');
  });

  test('inserta una unidad correctamente', () async {
    await unidadProvider.insertUnidad('Gramos');

    expect(unidadProvider.unidades.length, 1);
    expect(unidadProvider.unidades.first.tipo, 'Gramos');
  });

  test('actualiza una unidad correctamente', () async {
    await unidadProvider.insertUnidad('Litros');

    final id = unidadProvider.unidades.first.id!;
    await unidadProvider.updateUnidad(id, 'Mililitros');

    expect(unidadProvider.unidades.first.tipo, 'Mililitros');
  });

  test('elimina una unidad correctamente', () async {
    await unidadProvider.insertUnidad('Piezas');

    final id = unidadProvider.unidades.first.id!;
    await unidadProvider.deleteUnidad(id);

    expect(unidadProvider.unidades.length, 0);
  });
}
