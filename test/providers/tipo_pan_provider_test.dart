import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:panes_app/db/db_provider.dart';
import 'package:panes_app/models/tipo_pan_model.dart';
import 'package:panes_app/providers/tipo_pan_provider.dart';

void main() {
  late TipoPanProvider tipoPanProvider;

  setUpAll(() async {
    sqfliteFfiInit();
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    DBProvider.overrideDatabase = db;

    await db.execute('''
      CREATE TABLE tipos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT,
        precio_base REAL,
        cantidad_por_charola INTEGER
      );
    ''');
  });

  setUp(() async {
    tipoPanProvider = TipoPanProvider();
    final db = await DBProvider.db.database;
    await db.delete('tipos');
  });

  test('inserta un tipo de pan correctamente', () async {
    final tipo = TipoPanModel(
      tipo: 'Concha',
      precioBase: 8.5,
      cantidadPorCharola: 12,
    );

    await tipoPanProvider.insertTipo(tipo);

    expect(tipoPanProvider.tipos.length, 1);
    expect(tipoPanProvider.tipos.first.tipo, 'Concha');
  });

  test('actualiza un tipo de pan correctamente', () async {
    final original = TipoPanModel(
      tipo: 'Bolillo',
      precioBase: 3.0,
      cantidadPorCharola: 20,
    );
    await tipoPanProvider.insertTipo(original);

    final actualizado = TipoPanModel(
      id: tipoPanProvider.tipos.first.id,
      tipo: 'Bolillo Especial',
      precioBase: 3.5,
      cantidadPorCharola: 24,
    );
    await tipoPanProvider.updateTipo(actualizado);

    expect(tipoPanProvider.tipos.first.tipo, 'Bolillo Especial');
    expect(tipoPanProvider.tipos.first.precioBase, 3.5);
  });

  test('elimina un tipo de pan correctamente', () async {
    final tipo = TipoPanModel(
      tipo: 'Cuernito',
      precioBase: 5.0,
      cantidadPorCharola: 10,
    );
    await tipoPanProvider.insertTipo(tipo);

    final id = tipoPanProvider.tipos.first.id!;
    await tipoPanProvider.deleteTipo(id);

    expect(tipoPanProvider.tipos.length, 0);
  });
}
