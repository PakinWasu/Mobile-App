import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';

class MonthlySummary extends StatefulWidget {
  @override
  _MonthlySummaryState createState() => _MonthlySummaryState();
}

class _MonthlySummaryState extends State<MonthlySummary> {
  String selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());

  // สีสำหรับรายรับ-รายจ่าย
  final incomeColor = Color(0xFF4CAF50);
  final expenseColor = Color(0xFFE57373);

  Map<String, double> _calculateCategorySums(
      List<Expense> expenses, String type, String month) {
    final categorySums = <String, double>{};
    final monthExpenses = expenses.where((expense) =>
        DateFormat('yyyy-MM').format(expense.date) == month &&
        expense.type == type);

    for (var expense in monthExpenses) {
      categorySums[expense.category] =
          (categorySums[expense.category] ?? 0) + expense.amount;
    }
    return categorySums;
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy-MM').parse(selectedMonth),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        selectedMonth = DateFormat('yyyy-MM').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final allExpenses = expenseProvider.expenses;
        final monthlyIncomes =
            _calculateCategorySums(allExpenses, 'รายรับ', selectedMonth);
        final monthlyExpenses =
            _calculateCategorySums(allExpenses, 'รายจ่าย', selectedMonth);

        // คำนวณยอดรวม
        final totalIncome =
            monthlyIncomes.values.fold(0.0, (sum, amount) => sum + amount);
        final totalExpense =
            monthlyExpenses.values.fold(0.0, (sum, amount) => sum + amount);
        final balance = totalIncome - totalExpense;

        return Column(
          children: [
            // ปุ่มเลือกเดือน
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () => _selectMonth(context),
                icon: Icon(Icons.calendar_today),
                label: Text(
                  DateFormat('MMMM yyyy', 'th')
                      .format(DateFormat('yyyy-MM').parse(selectedMonth)),
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            // เพิ่มส่วนสรุปรายเดือน
            Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      'สรุปประจำเดือน',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMonthlySummaryItem(
                          'รายรับ',
                          totalIncome,
                          Colors.green,
                        ),
                        _buildMonthlySummaryItem(
                          'รายจ่าย',
                          totalExpense,
                          Colors.red,
                        ),
                        _buildMonthlySummaryItem(
                          'คงเหลือ',
                          balance,
                          balance >= 0 ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // ส่วนแสดงรายละเอียดรายรับ-รายจ่าย
            Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'รายรับ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  ...monthlyIncomes.entries.map((entry) {
                                    final percentage = monthlyIncomes.values
                                                .fold(
                                                    0.0,
                                                    (sum, amount) =>
                                                        sum + amount) >
                                            0
                                        ? (entry.value /
                                            monthlyIncomes.values.fold(0.0,
                                                (sum, amount) => sum + amount) *
                                            100)
                                        : 0.0;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(entry.key),
                                          SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${NumberFormat('#,##0.00').format(entry.value)}',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${percentage.toStringAsFixed(1)}%',
                                                style: TextStyle(
                                                  color: Colors.green[300],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          LinearProgressIndicator(
                                            value: percentage / 100,
                                            backgroundColor: Colors.grey[200],
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.green),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'รายจ่าย',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  ...monthlyExpenses.entries.map((entry) {
                                    final percentage = monthlyExpenses.values
                                                .fold(
                                                    0.0,
                                                    (sum, amount) =>
                                                        sum + amount) >
                                            0
                                        ? (entry.value /
                                            monthlyExpenses.values.fold(0.0,
                                                (sum, amount) => sum + amount) *
                                            100)
                                        : 0.0;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(entry.key),
                                          SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${NumberFormat('#,##0.00').format(entry.value)}',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${percentage.toStringAsFixed(1)}%',
                                                style: TextStyle(
                                                  color: Colors.red[300],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          LinearProgressIndicator(
                                            value: percentage / 100,
                                            backgroundColor: Colors.grey[200],
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.red),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // เพิ่มวิดเจ็ตสำหรับแสดงสรุปรายเดือน
  Widget _buildMonthlySummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          NumberFormat('#,##0.00').format(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          'บาท',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
