import 'package:flutter/material.dart';

class DialogUtils {
  static void showResultDialog(
    BuildContext context, {
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: message
                .split('\n')
                .map((line) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        line,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              child: Text(
                'ตกลง',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
