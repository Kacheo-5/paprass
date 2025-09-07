import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.expense == null ? 'Nouvelle dépense' : 'Modifier dépense',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6B7280)),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations de la dépense',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        label: 'Type de dépense',
                        icon: Icons.category_outlined,
                        initialValue: expenseType,
                        onChanged: (v) => expenseType = v,
                        validator: (v) => v!.isEmpty ? 'Ce champ est requis' : null,
                        hint: 'Ex: Restaurant, Transport, Shopping...',
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Date',
                        icon: Icons.calendar_today_outlined,
                        initialValue: date,
                        onChanged: (v) => date = v,
                        validator: (v) => v!.isEmpty ? 'Ce champ est requis' : null,
                        hint: 'YYYY-MM-DD',
                        keyboardType: TextInputType.datetime,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Quantité (optionnel)',
                        icon: Icons.inventory_2_outlined,
                        initialValue: quantity,
                        onChanged: (v) => quantity = v,
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          final n = double.tryParse(v.replaceAll(',', '.'));
                          return n == null ? 'Doit être un nombre valide' : null;
                        },
                        hint: 'Ex: 2, 1.5, 10...',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Montant',
                        icon: Icons.euro_outlined,
                        initialValue: amount,
                        onChanged: (v) => amount = v,
                        validator: (v) => v!.isEmpty ? 'Ce champ est requis' : null,
                        hint: 'Ex: 25.50',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: isLoading
                  ? ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.grey[600],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B7280)),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Enregistrement...'),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _submit();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.expense == null ? Icons.add : Icons.edit,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.expense == null ? 'Enregistrer' : 'Modifier',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String initialValue,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF6B7280),
              size: 20,
            ),
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
