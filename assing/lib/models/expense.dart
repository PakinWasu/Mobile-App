class Expense {
  final int? id; // Primary key for database
  final String type; // รายรับหรือรายจ่าย
  final String category;
  final double amount;
  final DateTime date;

  Expense({
    this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
  });

  // Convert Expense object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  // Create Expense object from Map
  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      type: map['type'],
      category: map['category'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
    );
  }
}
