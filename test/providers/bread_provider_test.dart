import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:panes_app/models/bread_model.dart';
import 'package:panes_app/providers/bread_provider.dart';
import 'package:panes_app/db/db_provider.dart';

void main() {
  late BreadProvider breadProvider;

  // Reemplaza la base de datos por una en memoria
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
              CREATE TABLE panes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                nombre TEXT,
                detalles TEXT,
                receta_unidad TEXT,
                precio REAL
              );
            ''');
        },
      ),
    );

    await db.execute('DELETE FROM panes'); // Limpia la tabla antes de cada test
    // Redirige la base de datos al test
    DBProvider.overrideDatabase = db;

    // Inicializa el provider
    breadProvider = BreadProvider();
    await breadProvider.loadBreads(); // inicializa lista vacía
  });

  test('agrega un pan correctamente', () async {
    final nuevoPan = PanModel(
      nombre: 'Concha',
      detalles: 'Dulce',
      recetaUnidad: 'unidad',
      precio: 6.0,
    );

    await breadProvider.addBread(nuevoPan);

    expect(breadProvider.breads.length, 1);
    expect(breadProvider.breads.first.nombre, 'Concha');
  });

  test('elimina un pan correctamente', () async {
    final pan = PanModel(
      nombre: 'Bolillo',
      detalles: 'Salado',
      recetaUnidad: 'unidad',
      precio: 2.5,
    );

    await breadProvider.addBread(pan);

    final panesAntes = breadProvider.breads;
    expect(panesAntes.length, 1); // Verifica que sí se insertó

    final id = panesAntes.first.id!;
    await breadProvider.deleteBread(id);

    final panesDespues = breadProvider.breads;
    expect(panesDespues.length, 0); // Aquí está fallando
  });

  test('actualiza un pan correctamente', () async {
    final pan = PanModel(
      nombre: 'Telera',
      detalles: 'Redonda',
      recetaUnidad: 'unidad',
      precio: 3.0,
    );

    await breadProvider.addBread(pan);

    final original = breadProvider.breads.first;

    final actualizado = PanModel(
      id: original.id,
      nombre: 'Telera Grande',
      detalles: original.detalles,
      recetaUnidad: original.recetaUnidad,
      precio: 4.5,
    );

    await breadProvider.updateBread(actualizado);

    final actualizadoEnLista = breadProvider.breads.first;
    expect(actualizadoEnLista.nombre, 'Telera Grande');
    expect(actualizadoEnLista.precio, 4.5);
  });
}
