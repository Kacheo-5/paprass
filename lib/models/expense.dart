class Expense {
  final int id;
  final String expenseType;
  final String date;
  final String quantity;
  final String amount;
  final String createdAt;

  Expense({
    required this.id,
    required this.expenseType,
    required this.date,
    required this.quantity,
    required this.amount,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    expenseType: json['expense_type'],
    date: json['date'],
    quantity: json['quantity'] ?? '',
    amount: json['amount'],
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toJson() => {
    'expense_type': expenseType,
    'date': date,
    'quantity': quantity,
    'amount': amount,
  };
}
