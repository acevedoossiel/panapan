import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:panes_app/db/db_provider.dart';
import 'package:panes_app/providers/pedido_detalle_provider.dart';

void main() {
  late PedidoDetalleProvider detalleProvider;

  setUpAll(() async {
    sqfliteFfiInit();
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    DBProvider.overrideDatabase = db;

    // Crear tabla 'tipos' (requerida por JOIN)
    await db.execute('''
      CREATE TABLE tipos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT,
        precio_base REAL,
        cantidad_por_charola INTEGER
      );
    ''');

    // Crear tabla 'pedido_cliente'
    await db.execute('''
      CREATE TABLE pedido_cliente (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_cliente INTEGER,
        fecha TEXT,
        total REAL
      );
    ''');

    // Crear tabla 'pedido_cliente_detalle'
    await db.execute('''
      CREATE TABLE pedido_cliente_detalle (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_pedido_cliente INTEGER,
        id_tipo_pan INTEGER,
        cantidad INTEGER,
        FOREIGN KEY (id_pedido_cliente) REFERENCES pedido_cliente(id),
        FOREIGN KEY (id_tipo_pan) REFERENCES tipos(id)
      );
    ''');

    // Insertar un tipo de pan de prueba
    await db.insert('tipos', {
      'tipo': 'Concha',
      'precio_base': 10.0,
      'cantidad_por_charola': 12,
    });

    // Insertar un pedido de prueba
    await db.insert('pedido_cliente', {
      'id_cliente': 1,
      'fecha': '2024-01-01',
      'total': 100.0,
    });
  });

  setUp(() async {
    detalleProvider = PedidoDetalleProvider();
    final db = await DBProvider.db.database;
    await db.delete('pedido_cliente_detalle');
  });

  test('inserta y carga un detalle de pedido correctamente', () async {
    await detalleProvider.insertDetalle(1, 1, 5);

    await detalleProvider.loadDetallesForPedido(1);

    expect(detalleProvider.detalles.length, 1);
    final detalle = detalleProvider.detalles.first;
    expect(detalle.idPedidoCliente, 1);
    expect(detalle.idTipoPan, 1);
    expect(detalle.cantidad, 5);
    expect(detalle.tipoPanNombre, 'Concha');
  });
}
