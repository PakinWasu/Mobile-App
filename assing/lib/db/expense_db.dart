import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class ExpenseDatabase {
  static final ExpenseDatabase instance = ExpenseDatabase._init();
  static Database? _database;

  ExpenseDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const expenseTable = '''
    CREATE TABLE expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT NOT NULL,
      category TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL
    )
    ''';
    await db.execute(expenseTable);
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await instance.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> fetchAllExpenses() async {
    final db = await instance.database;
    final result = await db.query('expenses');

    return result.map((map) => Expense.fromMap(map)).toList();
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await instance.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
