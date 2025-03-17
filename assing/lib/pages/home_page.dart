import 'package:flutter/material.dart';
import '../widgets/summary_chart.dart';
import '../widgets/monthly_summary.dart';
import 'add_expense_page.dart';
import 'expense_list_page.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Provider.of<ExpenseProvider>(context, listen: false).initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แอปรายรับรายจ่าย'),
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
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.45,
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: SummaryChart(),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: MonthlySummary(),
                  ),
                  SizedBox(height: 60),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
