import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';

class SummaryChart extends StatefulWidget {
  @override
  _SummaryChartState createState() => _SummaryChartState();
}

class _SummaryChartState extends State<SummaryChart> {
  Map<String, double> _calculateTotalSums(List<Expense> expenses, String type) {
    // คำนวณยอดรวมทั้งหมดของแต่ละประเภท
    final filteredExpenses = expenses.where((expense) => expense.type == type);
    return {
      'total':
          filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount)
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final allExpenses = expenseProvider.expenses;
        final totalIncomes = _calculateTotalSums(allExpenses, 'รายรับ');
        final totalExpenses = _calculateTotalSums(allExpenses, 'รายจ่าย');

        final totalIncome = totalIncomes['total'] ?? 0.0;
        final totalExpense = totalExpenses['total'] ?? 0.0;
        final total = totalIncome + totalExpense;

        // สีสำหรับรายรับ-รายจ่าย
        final incomeColor = Color(0xFF4CAF50); // สีเขียว
        final expenseColor = Color(0xFFE57373); // สีแดง

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'สรุปรายรับ-รายจ่ายทั้งหมด',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Chart และ Legend
            Expanded(
              child: Row(
                children: [
                  // Legend ด้านซ้าย
                  Container(
                    width: 120,
                    padding: EdgeInsets.only(right: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem(
                          'รายรับ',
                          '${NumberFormat('#,##0.00').format(totalIncome)}\n(${total > 0 ? (totalIncome / total * 100).toStringAsFixed(1) : 0}%)',
                          incomeColor,
                        ),
                        SizedBox(height: 16),
                        _buildLegendItem(
                          'รายจ่าย',
                          '${NumberFormat('#,##0.00').format(totalExpense)}\n(${total > 0 ? (totalExpense / total * 100).toStringAsFixed(1) : 0}%)',
                          expenseColor,
                        ),
                      ],
                    ),
                  ),
                  // Chart
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: incomeColor,
                              value: totalIncome,
                              title: '',
                              radius: 60,
                            ),
                            PieChartSectionData(
                              color: expenseColor,
                              value: totalExpense,
                              title: '',
                              radius: 60,
                            ),
                          ],
                          centerSpaceRadius: 0,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ยอดคงเหลือ
            Container(
              padding: EdgeInsets.only(top: 16),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    children: [
                      Text(
                        'ยอดคงเหลือทั้งหมด',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${NumberFormat('#,##0.00').format(totalIncome - totalExpense)} บาท',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: (totalIncome - totalExpense) >= 0
                              ? Theme.of(context).primaryColor
                              : Color(0xFFB8A7D4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
