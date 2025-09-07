import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';
import 'expense_form_screen.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final ExpenseService service;
  final int expenseId;
  ExpenseDetailScreen({required this.service, required this.expenseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détail dépense')),
      body: FutureBuilder<Expense>(
        future: service.getExpense(expenseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Erreur'));
          final expense = snapshot.data;
          if (expense == null) return Center(child: Text('Non trouvé'));
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Type: ${expense.expenseType}',
                  style: TextStyle(fontSize: 18),
                ),
                Text('Date: ${expense.date}'),
                Text('Quantité: ${expense.quantity}'),
                Text('Montant: ${expense.amount}'),
                Text('Créé le: ${expense.createdAt}'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpenseFormScreen(
                          service: service,
                          expense: expense,
                        ),
                      ),
                    );
                    Navigator.pop(context); // Revenir à la liste après modif
                  },
                  child: Text('Modifier'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await service.deleteExpense(expense.id);
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur suppression')),
                      );
                    }
                  },
                  child: Text('Supprimer'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
