import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';

class ExpenseFormScreen extends StatefulWidget {
  final ExpenseService service;
  final Expense? expense;
  ExpenseFormScreen({Key? key, required this.service, this.expense})
    : super(key: key);

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String expenseType;
  late String date;
  late String quantity;
  late String amount;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    expenseType = widget.expense?.expenseType ?? '';
    date = widget.expense?.date ?? '';
    quantity = widget.expense?.quantity ?? '';
    amount = widget.expense?.amount ?? '';
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        if (widget.expense == null) {
          final expense = Expense(
            id: 0,
            expenseType: expenseType,
            date: date,
            quantity: quantity,
            amount: amount,
            createdAt: '',
          );
          await widget.service.createExpense(expense);
        } else {
          await widget.service.updateExpense(widget.expense!.id, {
            'expense_type': expenseType,
            'date': date,
            'quantity': quantity,
            'amount': amount,
          });
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur')));
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.expense == null ? 'Nouvelle dépense' : 'Modifier dépense',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Type'),
                initialValue: expenseType,
                onChanged: (v) => expenseType = v,
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                initialValue: date,
                onChanged: (v) => date = v,
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Quantité'),
                initialValue: quantity,
                onChanged: (v) => quantity = v,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  return n == null ? 'Doit être un nombre' : null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Montant'),
                initialValue: amount,
                onChanged: (v) => amount = v,
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        widget.expense == null ? 'Enregistrer' : 'Modifier',
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
