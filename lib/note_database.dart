import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'note.dart';

class NoteDatabase {
  static final NoteDatabase instance = NoteDatabase._init();
  static Database? _database;

  NoteDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${NoteFields.tableName} (
        ${NoteFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${NoteFields.titulo} TEXT NOT NULL,
        ${NoteFields.calificacion} REAL NOT NULL,
        ${NoteFields.esImportante} INTEGER NOT NULL,
        ${NoteFields.fechaCreacion} TEXT NOT NULL
      )
    ''');
  }

  Future<NoteModel> create(NoteModel note) async {
    final db = await instance.database;
    final id = await db.insert(NoteFields.tableName, note.toJson());
    return note.copy(id: id);
  }

  Future<NoteModel> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      NoteFields.tableName,
      columns: NoteFields.values,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return NoteModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id no encontrado');
    }
  }

  Future<List<NoteModel>> readAll() async {
    final db = await instance.database;
    const orderBy = '${NoteFields.fechaCreacion} DESC';
    final result = await db.query(NoteFields.tableName, orderBy: orderBy);
    return result.map((e) => NoteModel.fromJson(e)).toList();
  }

  Future<int> update(NoteModel note) async {
    final db = await instance.database;
    return db.update(
      NoteFields.tableName,
      note.toJson(),
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      NoteFields.tableName,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
