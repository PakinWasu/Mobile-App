import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../utils/dialog_utils.dart';

class ExpenseListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการทั้งหมด'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final expenses = provider.expenses;
          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ยังไม่มีรายการ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          expenses.sort((a, b) => b.date.compareTo(a.date));
          final groupedExpenses = _groupExpensesByDate(expenses);
          final sortedDates = groupedExpenses.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.05),
                  Colors.white,
                ],
              ),
            ),
            child: ListView.builder(
              padding: EdgeInsets.only(top: 8),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final dateStr = sortedDates[index];
                final dayExpenses = groupedExpenses[dateStr]!;

                // คำนวณยอดรวมของวัน
                double dailyTotal = 0;
                double dailyIncome = 0;
                double dailyExpense = 0;
                for (var expense in dayExpenses) {
                  if (expense.type == 'รายรับ') {
                    dailyIncome += expense.amount;
                  } else {
                    dailyExpense += expense.amount;
                  }
                  dailyTotal += expense.type == 'รายรับ'
                      ? expense.amount
                      : -expense.amount;
                }

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      // ส่วนหัวของวัน
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  _formatDateHeader(dateStr),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${dailyTotal >= 0 ? "+" : ""}${currencyFormat.format(dailyTotal)}',
                              style: TextStyle(
                                color: dailyTotal >= 0
                                    ? incomeColor
                                    : expenseColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // รายการแต่ละรายการ
                      ...dayExpenses
                          .map((expense) => Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                        color: Colors.grey.withOpacity(0.1)),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  leading: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: expense.type == 'รายจ่าย'
                                          ? expenseLightColor
                                          : incomeLightColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      expense.type == 'รายจ่าย'
                                          ? Icons.remove_circle_outline
                                          : Icons.add_circle_outline,
                                      color: expense.type == 'รายจ่าย'
                                          ? expenseColor
                                          : incomeColor,
                                    ),
                                  ),
                                  title: Text(
                                    expense.category,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    DateFormat('HH:mm').format(expense.date),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${expense.type == 'รายจ่าย' ? "-" : "+"}${currencyFormat.format(expense.amount)}',
                                        style: TextStyle(
                                          color: expense.type == 'รายจ่าย'
                                              ? expenseColor
                                              : incomeColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      PopupMenuButton(
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: Colors.grey[600],
                                        ),
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            child: ListTile(
                                              leading: Icon(Icons.edit,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              title: Text('แก้ไข'),
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            onTap: () {
                                              // ต้องใช้ Future.delayed เพราะ PopupMenuItem ต้องการเวลาในการปิดตัวเอง
                                              Future.delayed(
                                                Duration.zero,
                                                () => _showEditDialog(
                                                    context, expense),
                                              );
                                            },
                                          ),
                                          PopupMenuItem(
                                            child: ListTile(
                                              leading: Icon(Icons.delete,
                                                  color: expenseColor),
                                              title: Text('ลบ'),
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            onTap: () {
                                              _handleDelete(context, expense);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Map<String, List<Expense>> _groupExpensesByDate(List<Expense> expenses) {
    final groups = <String, List<Expense>>{};

    for (var expense in expenses) {
      final dateStr = DateFormat('yyyy-MM-dd').format(expense.date);
      if (!groups.containsKey(dateStr)) {
        groups[dateStr] = [];
      }
      groups[dateStr]!.add(expense);
    }

    return groups;
  }

  final currencyFormat = NumberFormat.currency(
    locale: 'th_TH',
    symbol: '',
    decimalDigits: 2,
  );

  // สีสำหรับรายรับ-รายจ่าย
  final incomeColor = Color(0xFF4CAF50);
  final expenseColor = Color(0xFFE57373);
  final incomeLightColor = Color(0xFFE8F5E9);
  final expenseLightColor = Color(0xFFFFEBEE);

  String _formatDateHeader(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final yesterday = DateTime.now().subtract(Duration(days: 1));

    if (DateFormat('yyyy-MM-dd').format(now) == dateStr) {
      return 'วันนี้';
    } else if (DateFormat('yyyy-MM-dd').format(yesterday) == dateStr) {
      return 'เมื่อวาน';
    }

    return DateFormat('d MMMM yyyy', 'th').format(date);
  }

  void _showEditDialog(BuildContext context, Expense expense) {
    final _formKey = GlobalKey<FormState>();
    String _category = expense.category;
    double _amount = expense.amount;
    String _type = expense.type;
    DateTime _selectedDate = expense.date;
    TimeOfDay _selectedTime = TimeOfDay.fromDateTime(expense.date);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(
              Icons.edit,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'แก้ไขรายการ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: InputDecoration(
                    labelText: 'ประเภท',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: ['รายรับ', 'รายจ่าย']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) => _type = value!,
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: _category,
                  decoration: InputDecoration(
                    labelText: 'หมวดหมู่',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onSaved: (value) => _category = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาระบุหมวดหมู่';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: _amount.toString(),
                  decoration: InputDecoration(
                    labelText: 'จำนวนเงิน',
                    prefixText: '฿',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onSaved: (value) => _amount = double.parse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาระบุจำนวนเงิน';
                    }
                    if (double.tryParse(value) == null) {
                      return 'กรุณาระบุตัวเลขที่ถูกต้อง';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ListTile(
                  title: Text(
                    'วันที่: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                  ),
                  trailing: Image.asset(
                    'assets/images/calendar.png',
                    width: 24,
                    height: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      _selectedDate = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        _selectedTime.hour,
                        _selectedTime.minute,
                      );
                    }
                  },
                ),
                SizedBox(height: 8),
                ListTile(
                  title: Text('เวลา: ${_selectedTime.format(context)}'),
                  trailing: Image.asset(
                    'assets/images/clock.png',
                    width: 24,
                    height: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (picked != null) {
                      _selectedTime = picked;
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        picked.hour,
                        picked.minute,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Navigator.pop(context);

                try {
                  final updatedExpense = Expense(
                    id: expense.id,
                    type: _type,
                    category: _category,
                    amount: _amount,
                    date: _selectedDate,
                  );

                  final message = await Provider.of<ExpenseProvider>(
                    context,
                    listen: false,
                  ).updateExpense(updatedExpense);

                  // แสดง popup ยืนยันการแก้ไข
                  DialogUtils.showResultDialog(
                    context,
                    title: 'แก้ไขสำเร็จ',
                    message: message,
                    isSuccess: true,
                  );
                } catch (e) {
                  DialogUtils.showResultDialog(
                    context,
                    title: 'เกิดข้อผิดพลาด',
                    message: e.toString(),
                    isSuccess: false,
                  );
                }
              }
            },
            child: Text(
              'บันทึก',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDelete(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('ยืนยันการลบ'),
            ],
          ),
          content: Text('คุณต้องการลบรายการนี้ใช่หรือไม่?'),
          actions: [
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'ลบ',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  final message =
                      await Provider.of<ExpenseProvider>(context, listen: false)
                          .deleteExpense(expense.id!);

                  DialogUtils.showResultDialog(
                    context,
                    title: 'ลบสำเร็จ',
                    message: message,
                    isSuccess: true,
                  );
                } catch (e) {
                  DialogUtils.showResultDialog(
                    context,
                    title: 'เกิดข้อผิดพลาด',
                    message: e.toString(),
                    isSuccess: false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
