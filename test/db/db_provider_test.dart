import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:panes_app/db/db_provider.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('Se ejecuta initDB y se crean todas las tablas', () async {
    final db =
        await DBProvider.db.initDB(); // Aquí llamas directamente al método
    final tablasEsperadas = [
      'unidades',
      'tipos',
      'panes',
      'ingredientes_catalogo',
      'receta_tipo_pan',
      'clientes',
      'pedido_cliente',
      'pedido_cliente_detalle',
    ];

    final List<Map<String, dynamic>> resultado = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    final tablasEnBD = resultado.map((e) => e['name'] as String).toList();

    for (final tabla in tablasEsperadas) {
      expect(
        tablasEnBD.contains(tabla),
        isTrue,
        reason: 'Falta la tabla $tabla',
      );
    }
  });
}
