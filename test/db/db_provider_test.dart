import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:panes_app/db/db_provider.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  test(
    'La base de datos se crea correctamente con las tablas esperadas',
    () async {
      final Database db = await DBProvider.db.database;

      final expectedTables = [
        'unidades',
        'tipos',
        'panes',
        'ingredientes_catalogo',
        'receta_tipo_pan',
        'clientes',
        'pedido_cliente',
        'pedido_cliente_detalle',
      ];

      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );

      final tablesInDb = result.map((row) => row['name'] as String).toList();

      for (var table in expectedTables) {
        expect(
          tablesInDb.contains(table),
          isTrue,
          reason: 'Falta la tabla $table',
        );
      }
    },
  );
}
