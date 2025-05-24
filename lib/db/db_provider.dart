import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  static Database? _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database> get database async {
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

        await db.execute('''
          CREATE TABLE tipos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE panes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            id_tipo INTEGER,
            precio REAL,
            FOREIGN KEY (id_tipo) REFERENCES tipos(id)
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
          CREATE TABLE receta_ingredientes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_pan INTEGER,
            id_ingrediente INTEGER,
            cantidad REAL,
            FOREIGN KEY (id_pan) REFERENCES panes(id),
            FOREIGN KEY (id_ingrediente) REFERENCES ingredientes_catalogo(id)
          );
        ''');

        await db.execute('''
          CREATE TABLE pedidos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fecha TEXT,
            total REAL
          );
        ''');

        await db.execute('''
          CREATE TABLE pedido_detalles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_pedido INTEGER,
            id_pan INTEGER,
            charolas INTEGER,
            FOREIGN KEY (id_pedido) REFERENCES pedidos(id),
            FOREIGN KEY (id_pan) REFERENCES panes(id)
          );
        ''');
      },
    );
  }
}
