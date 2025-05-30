import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:panes_app/db/db_provider.dart';
import 'package:panes_app/models/cliente_model.dart';
import 'package:panes_app/providers/cliente_provider.dart';

void main() {
  late ClienteProvider clienteProvider;

  setUpAll(() async {
    sqfliteFfiInit();
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    DBProvider.overrideDatabase = db;

    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        direccion TEXT,
        telefono TEXT
      );
    ''');
  });

  setUp(() async {
    clienteProvider = ClienteProvider();
    await DBProvider.db.database.then((db) => db.delete('clientes'));
  });

  test('inserta un cliente correctamente', () async {
    final cliente = ClienteModel(
      nombre: 'Juan Pérez',
      direccion: 'Calle Falsa 123',
      telefono: '555-1234',
    );

    await clienteProvider.insertCliente(cliente);

    expect(clienteProvider.clientes.length, 1);
    expect(clienteProvider.clientes.first.nombre, 'Juan Pérez');
  });

  test('actualiza un cliente correctamente', () async {
    final cliente = ClienteModel(
      nombre: 'Ana López',
      direccion: 'Av. Principal 456',
      telefono: '555-5678',
    );
    await clienteProvider.insertCliente(cliente);

    final actualizado = ClienteModel(
      id: clienteProvider.clientes.first.id,
      nombre: 'Ana Gómez',
      direccion: 'Av. Principal 456',
      telefono: '555-5678',
    );

    await clienteProvider.updateCliente(actualizado);

    expect(clienteProvider.clientes.first.nombre, 'Ana Gómez');
  });

  test('elimina un cliente correctamente', () async {
    final cliente = ClienteModel(
      nombre: 'Carlos Ruiz',
      direccion: 'Calle Norte 789',
      telefono: '555-9012',
    );
    await clienteProvider.insertCliente(cliente);

    final id = clienteProvider.clientes.first.id!;
    await clienteProvider.deleteCliente(id);

    expect(clienteProvider.clientes.length, 0);
  });
}
