import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';
import '../utils/dialog_utils.dart';

class AddExpensePage extends StatefulWidget {
  final VoidCallback onSave;

  const AddExpensePage({Key? key, required this.onSave}) : super(key: key);

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'รายจ่าย';
  String _category = '';
  double _amount = 0;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final DateTime combinedDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        final message =
            await Provider.of<ExpenseProvider>(context, listen: false)
                .addExpense(Expense(
          type: _type,
          category: _category,
          amount: _amount,
          date: combinedDateTime,
        ));

        if (mounted) {
          DialogUtils.showResultDialog(
            context,
            title: 'บันทึกสำเร็จ',
            message: message,
            isSuccess: true,
          );
        }

        _formKey.currentState!.reset();
        setState(() {
          _type = 'รายจ่าย';
          _selectedDate = DateTime.now();
          _selectedTime = TimeOfDay.now();
        });

        widget.onSave();
      } catch (e) {
        if (mounted) {
          DialogUtils.showResultDialog(
            context,
            title: 'เกิดข้อผิดพลาด',
            message: e.toString(),
            isSuccess: false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เพิ่มรายการ'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF4F0FB), // ม่วงพาสเทลอ่อน
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ส่วนเลือกประเภทรายรับ/รายจ่าย
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF9D7EE0).withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _type = 'รายรับ'),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: _type == 'รายรับ'
                                    ? Color(0xFF7ED1A8).withOpacity(0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: Text(
                                  'รายรับ',
                                  style: TextStyle(
                                    color: _type == 'รายรับ'
                                        ? Color(0xFF2E9E6B)
                                        : Colors.grey,
                                    fontWeight: _type == 'รายรับ'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _type = 'รายจ่าย'),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: _type == 'รายจ่าย'
                                    ? Color(0xFFFF9B9B).withOpacity(0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: Text(
                                  'รายจ่าย',
                                  style: TextStyle(
                                    color: _type == 'รายจ่าย'
                                        ? Color(0xFFE55757)
                                        : Colors.grey,
                                    fontWeight: _type == 'รายจ่าย'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // ส่วนกรอกจำนวนเงิน
                  Text(
                    'จำนวนเงิน',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        prefixText: '฿ ',
                        prefixStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: _type == 'รายรับ' ? Colors.green : Colors.red,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาระบุจำนวนเงิน';
                        }
                        if (double.tryParse(value) == null) {
                          return 'กรุณาระบุตัวเลขที่ถูกต้อง';
                        }
                        return null;
                      },
                      onSaved: (value) => _amount = double.parse(value!),
                    ),
                  ),
                  SizedBox(height: 24),

                  // ส่วนหมวดหมู่
                  Text(
                    'หมวดหมู่',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'ระบุหมวดหมู่',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาระบุหมวดหมู่';
                        }
                        return null;
                      },
                      onSaved: (value) => _category = value!,
                    ),
                  ),
                  SizedBox(height: 24),

                  // ส่วนวันที่และเวลา
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/calendar.png',
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(_selectedDate),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (picked != null) {
                              setState(() => _selectedTime = picked);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/clock.png',
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  _selectedTime.format(context),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),

                  // ปุ่มบันทึก
                  Container(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveExpense,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'บันทึก',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
