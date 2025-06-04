import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  static Database? _database;
  static Database? _testDb;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  static set overrideDatabase(Database db) {
    _testDb = db;
  }

  Future<Database> get database async {
    if (_testDb != null) return _testDb!;
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'panapan.db');

    return await openDatabase(
      path,
      version: 1,
      
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE unidades (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo TEXT
          );
        ''');

        await insertarUnidadesPorDefecto(db);

        await db.execute('''
          CREATE TABLE tipos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo TEXT,
            precio_base REAL,
            cantidad_por_charola INTEGER
          );
        ''');

        await db.execute('''
          CREATE TABLE panes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            detalles TEXT,
            receta_unidad TEXT,
            precio REAL
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
            FOREIGN KEY (id_tipo_pan) REFERENCES tipos(id),
            FOREIGN KEY (id_ingrediente) REFERENCES ingredientes_catalogo(id),
            FOREIGN KEY (id_unidad) REFERENCES unidades(id)
          );
        ''');

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
      },
    );
  }

  Future<void> insertarUnidadesPorDefecto(Database db) async {
  final List<Map<String, dynamic>> unidadesActuales = await db.query('unidades');

  final List<String> tiposExistentes = unidadesActuales.map((u) => u['tipo'].toString()).toList();

  final List<String> unidadesPorDefecto = ['pz', 'ml', 'gr'];

  for (var tipo in unidadesPorDefecto) {
    if (!tiposExistentes.contains(tipo)) {
      await db.insert('unidades', {'tipo': tipo});
    }
  }
}

}
