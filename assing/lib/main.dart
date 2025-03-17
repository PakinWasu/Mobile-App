import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'navigation/main_navigator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// Main Application File
void main() async {
  // ต้องเรียกใช้เพื่อให้แน่ใจว่า Flutter bindings ถูก initialize ก่อนเรียกใช้ native code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale สำหรับการแสดงผลภาษาไทย
  await initializeDateFormatting('th_TH', null);
  Intl.defaultLocale = 'th_TH';

  // สร้างและ initialize provider สำหรับจัดการข้อมูล
  final expenseProvider = ExpenseProvider();
  await expenseProvider.initializeData();

  // เริ่มต้น Application
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: expenseProvider),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ExpenseProvider()..initializeData(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Expense Tracker',
        theme: ThemeData(
          primaryColor: Color(0xFF9D7EE0),
          primarySwatch: MaterialColor(0xFF9D7EE0, {
            50: Color(0xFFF4F0FB),
            100: Color(0xFFE3D7F5),
            200: Color(0xFFD1BCEF),
            300: Color(0xFFBEA1E8),
            400: Color(0xFFAB8BE4),
            500: Color(0xFF9D7EE0),
            600: Color(0xFF8F73D8),
            700: Color(0xFF7E65CF),
            800: Color(0xFF6E57C7),
            900: Color(0xFF533DB9),
          }),
          scaffoldBackgroundColor: Color(0xFFFAF8FF),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF9D7EE0),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF9D7EE0),
              foregroundColor: Colors.white,
              elevation: 2,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF9C89B8),
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Color(0xFF9D7EE0), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          colorScheme: ColorScheme.light(
            primary: Color(0xFF9D7EE0),
            secondary: Color(0xFFB19BE6),
            surface: Colors.white,
            background: Color(0xFFFAF8FF),
            error: Color(0xFFFF6B6B),
          ),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        home: MainNavigator(),
      ),
    );
  }
}
