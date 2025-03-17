import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';

// Provider Class สำหรับจัดการข้อมูลรายรับ-รายจ่าย
class ExpenseProvider with ChangeNotifier {
  // ตัวแปรเก็บข้อมูล
  List<Expense> _expenses = []; // เก็บรายการรายรับ-รายจ่ายทั้งหมด
  bool _isLoading = true; // สถานะการโหลดข้อมูล
  Database? _database; // ตัวแปรสำหรับจัดการฐานข้อมูล SQLite

  // Getters
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  // เมธอดสำหรับเชื่อมต่อฐานข้อมูล
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDatabase();
    return _database!;
  }

  // สร้างฐานข้อมูลและตาราง
  Future<Database> initializeDatabase() async {
    final String path = join(await getDatabasesPath(), 'expenses.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // สร้างตาราง expenses
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT,
            category TEXT,
            amount REAL,
            date TEXT
          )
        ''');
      },
    );
  }

  // โหลดข้อมูลจากฐานข้อมูล
  Future<void> initializeData() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('expenses');

      // แปลงข้อมูลจาก database เป็น Expense objects
      _expenses = List.generate(maps.length, (i) {
        return Expense(
          id: maps[i]['id'],
          type: maps[i]['type'],
          category: maps[i]['category'],
          amount: maps[i]['amount'],
          date: DateTime.parse(maps[i]['date']),
        );
      });
    } catch (e) {
      print('Error loading expenses: $e');
      _expenses = [];
    } finally {
      _isLoading = false;
      notifyListeners(); // แจ้งเตือน widgets ที่ใช้ข้อมูลให้ rebuild
    }
  }

  // เพิ่มรายการใหม่
  Future<String> addExpense(Expense expense) async {
    try {
      final db = await database;
      // เพิ่มข้อมูลลงฐานข้อมูล
      final id = await db.insert(
        'expenses',
        expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // สร้าง object ใหม่พร้อม id
      final newExpense = Expense(
        id: id,
        type: expense.type,
        category: expense.category,
        amount: expense.amount,
        date: expense.date,
      );

      _expenses.add(newExpense);
      notifyListeners();

      // ส่งข้อความยืนยันการเพิ่มข้อมูล
      return 'เพิ่มรายการ ${expense.type}\nหมวดหมู่: ${expense.category}\nจำนวนเงิน: ${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(expense.amount)}';
    } catch (e) {
      throw 'เกิดข้อผิดพลาดในการเพิ่มรายการ: $e';
    }
  }

  // อัพเดทรายการที่มีอยู่
  Future<String> updateExpense(Expense expense) async {
    try {
      final db = await database;
      await db.update(
        'expenses',
        expense.toMap(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );

      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
        notifyListeners();
      }

      return 'แก้ไขรายการสำเร็จ\nหมวดหมู่: ${expense.category}\nจำนวนเงิน: ${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(expense.amount)}';
    } catch (e) {
      throw 'เกิดข้อผิดพลาดในการแก้ไขรายการ: $e';
    }
  }

  // ลบรายการ
  Future<String> deleteExpense(int id) async {
    try {
      final expense = _expenses.firstWhere((e) => e.id == id);
      final db = await database;
      await db.delete(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );

      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();

      return 'ลบรายการสำเร็จ\nหมวดหมู่: ${expense.category}\nจำนวนเงิน: ${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(expense.amount)}';
    } catch (e) {
      throw 'เกิดข้อผิดพลาดในการลบรายการ: $e';
    }
  }

  Future<List<String>> getUsedCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      distinct: true,
      columns: ['category'],
      orderBy: 'category ASC',
    );

    return maps.map((map) => map['category'] as String).toList();
  }
}
