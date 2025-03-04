import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:qarz_daftar/core/models/debtor.dart';
import 'package:qarz_daftar/core/models/transaction.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'debtor_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE debtors (
        id TEXT PRIMARY KEY,
        name TEXT,
        balance REAL,
        isDebt INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        debtorId TEXT,
        amount REAL,
        date INTEGER,
        description TEXT,
        isDebt INTEGER,
        FOREIGN KEY (debtorId) REFERENCES debtors(id)
      )
    ''');
  }

  // Debtorlarni saqlash
  Future<void> insertDebtor(Debtor debtor) async {
    final db = await database;
    await db.insert(
      'debtors',
      {
        'id': debtor.id,
        'name': debtor.name,
        'balance': debtor.balance,
        'isDebt': debtor.isDebt ? 1 : 0, //bool intga aylantirildi
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Transactionni saqlash
  Future<void> insertTransaction(Transactions transaction) async {
    final db = await database;
    await db.insert(
      'transactions',
      {
        'id': transaction.id,
        'debtorId': transaction.debtorId,
        'amount': transaction.amount,
        'date': transaction.date.millisecondsSinceEpoch,
        'description': transaction.description,
        'isDebt': transaction.isDebt ? 1 : 0, //bool intga aylantirildi
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  //debtor malumotlarini olish
  Future<List<Debtor>> getAllDebtors() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('debtors');
    return List.generate(maps.length, (i) {
      return Debtor(
        id: maps[i]['id'],
        name: maps[i]['name'],
        balance: maps[i]['balance'],
        isDebt: maps[i]['isDebt'] == 1 ? true : false,
      );
    });
  }

  //transaction malumotlarini olish
  Future<List<Transactions>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    return List.generate(maps.length, (i) {
      return Transactions(
        id: maps[i]['id'],
        debtorId: maps[i]['debtorId'],
        amount: maps[i]['amount'],
        date: DateTime.fromMillisecondsSinceEpoch(maps[i]['date']),
        description: maps[i]['description'],
        isDebt: maps[i]['isDebt'] == 1 ? true : false,
      );
    });
  }
  // Debtor ni o'chirish
  Future<void> deleteDebtor(String id) async {
    final db = await database;
    await db.delete(
      'debtors',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Transaction ni o'chirish
  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}