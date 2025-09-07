import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/expense.dart';

class ExpenseService {
  final String baseUrl;
  final String? token;

  ExpenseService({
    this.baseUrl = 'http://10.0.2.2:8000/api/depenses/',
    this.token,
  });

  Map<String, String> getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Token $token';
    return headers;
  }

  Future<List<Expense>> fetchExpenses({
    String? search,
    String? ordering,
  }) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/depenses/'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Expense.fromJson(e)).toList();
    }
    throw Exception('Erreur de chargement');
  }

  Future<Expense> createExpense(Expense expense) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: getHeaders(),
      body: jsonEncode(expense.toJson()),
    );
    if (response.statusCode == 201) {
      return Expense.fromJson(jsonDecode(response.body));
    }
    // Propagate server validation message when available
    String body = response.body;
    String msg = 'Erreur de création (${response.statusCode})';
    try {
      final parsed = jsonDecode(body);
      if (parsed is Map && parsed.isNotEmpty) {
        msg = parsed.toString();
      } else if (body.isNotEmpty) {
        msg = body;
      }
    } catch (_) {
      if (body.isNotEmpty) msg = body;
    }
    throw Exception(msg);
  }

  Future<Expense> getExpense(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl$id/'),
      headers: getHeaders(),
    );
    if (response.statusCode == 200) {
      return Expense.fromJson(jsonDecode(response.body));
    }
    throw Exception('Dépense non trouvée');
  }

  Future<Expense> updateExpense(int id, Map<String, dynamic> fields) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$id/'),
      headers: getHeaders(),
      body: jsonEncode(fields),
    );
    if (response.statusCode == 200) {
      return Expense.fromJson(jsonDecode(response.body));
    }
    throw Exception('Erreur de modification');
  }

  Future<void> deleteExpense(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$id/'),
      headers: getHeaders(),
    );
    if (response.statusCode != 204) {
      throw Exception('Erreur de suppression');
    }
  }
}
