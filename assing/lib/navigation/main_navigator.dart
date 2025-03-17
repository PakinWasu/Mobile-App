import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/add_expense_page.dart';
import '../pages/expense_list_page.dart';

class MainNavigator extends StatefulWidget {
  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(),
          AddExpensePage(
            onSave: () {
              setState(() {
                _selectedIndex = 0;
              });
            },
          ),
          ExpenseListPage(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, 'assets/images/home.png'),
              _buildNavItem(1, 'assets/images/add.png'),
              _buildNavItem(2, 'assets/images/list.png'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String imagePath) {
    bool isSelected = _selectedIndex == index;

    double iconSize = index == 1 ? 65.0 : 52.0;

    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 2.5,
                )
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Container(
                width: iconSize + 25,
                height: iconSize + 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            ImageIcon(
              AssetImage(imagePath),
              size: iconSize,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[400]?.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }
}
