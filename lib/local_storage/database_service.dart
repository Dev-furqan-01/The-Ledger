import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../features/dashboard/models/transaction_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory dir = await getApplicationDocumentsDirectory();
    final dbDirPath = join(dir.path, 'Zepensia');
    if (!await Directory(dbDirPath).exists()) {
      await Directory(dbDirPath).create(recursive: true);
    }
    final path = join(dbDirPath, 'zepensia.db');

    if (Platform.isAndroid && !await File(path).exists()) {
      const legacyPath = '/storage/emulated/0/Documents/Zepensia/zepensia.db';
      final legacyFile = File(legacyPath);
      try {
        if (await legacyFile.exists()) {
          await legacyFile.copy(path);
        }
      } catch (_) {}
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        date TEXT,
        category TEXT,
        amount REAL,
        type INTEGER,
        icon INTEGER
      )
    ''');
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    Database db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions({int? limit, int? offset}) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  Future<void> insertTransactions(List<TransactionModel> transactions) async {
    Database db = await database;
    Batch batch = db.batch();
    for (var tx in transactions) {
      batch.insert('transactions', tx.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<int> deleteTransaction(int id) async {
    Database db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    Database db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> clearAll() async {
    Database db = await database;
    await db.delete('transactions');
  }
}
