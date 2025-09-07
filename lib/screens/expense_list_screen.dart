import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';

class ExpenseListScreen extends StatefulWidget {
  final ExpenseService service;
  ExpenseListScreen({required this.service});

  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  late Future<List<Expense>> expenses;

  @override
  void initState() {
    super.initState();
    expenses = widget.service.fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dépenses')),
      body: FutureBuilder<List<Expense>>(
        future: expenses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }
          final data = snapshot.data ?? [];
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(data[i].expenseType),
              subtitle: Text('${data[i].amount} - ${data[i].date}'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: {'id': data[i].id},
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add');
          setState(() {
            expenses = widget.service.fetchExpenses();
          });
        },
        child: Icon(Icons.add),
        tooltip: 'Ajouter une dépense',
      ),
    );
  }
}
