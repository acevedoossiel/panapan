import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:panes_app/db/db_provider.dart';
import 'package:panes_app/models/pedido_cliente_model.dart';
import 'package:panes_app/providers/pedido_provider.dart';

void main() {
  late PedidoProvider pedidoProvider;

  setUpAll(() async {
    sqfliteFfiInit();
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    DBProvider.overrideDatabase = db;

    // Crear las tablas necesarias
    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        direccion TEXT,
        telefono TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE pedido_cliente (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_cliente INTEGER,
        fecha TEXT,
        total REAL,
        FOREIGN KEY (id_cliente) REFERENCES clientes(id)
      );
    ''');
  });

  setUp(() async {
    pedidoProvider = PedidoProvider();
    final db = await DBProvider.db.database;
    await db.delete('pedido_cliente');
    await db.delete('clientes');
  });

  test('inserta un pedido correctamente', () async {
    final db = await DBProvider.db.database;

    // Insertar cliente primero (porque pedido_cliente depende de él)
    final clienteId = await db.insert('clientes', {
      'nombre': 'Juan Pérez',
      'direccion': 'Calle Falsa 123',
      'telefono': '555-1234',
    });

    final pedido = PedidoClienteModel(
      idCliente: clienteId,
      fecha: '2025-05-30',
      total: 100.0,
    );

    final nuevoId = await pedidoProvider.insertPedido(pedido);

    expect(nuevoId, greaterThan(0));
    expect(pedidoProvider.pedidos.length, 1);
    expect(pedidoProvider.pedidos.first.total, 100.0);
    expect(pedidoProvider.pedidos.first.nombreCliente, 'Juan Pérez');
  });
}
