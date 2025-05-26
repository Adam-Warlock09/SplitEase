import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:split_ease/models/expense.dart';
import 'package:split_ease/models/group.dart';
import 'package:split_ease/models/groupDetailed.dart';
import 'package:split_ease/models/settlement.dart';
import 'package:split_ease/models/transaction.dart';
import 'package:split_ease/models/user.dart';

class ApiService {

  final String baseUrl = 'http://localhost:8080';

  Future<List<Settlement>> fetchSettlementsByGroupID(String groupID, String? token) async {

    if(token == null) {
      return [];
    }

    try {

      final response = await http.get(
        Uri.parse('$baseUrl/api/group/$groupID/settle'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.trim() == "null") {
          return [];
        }
        final List<dynamic> data = json.decode(response.body);
        return data.map((settlement) => Settlement.fromJson(settlement)).toList();
      } else {
        print('Failed to fetch settlements: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching settlements: $e');
      return [];
    }

  }

  Future<Transaction?> createTransaction(String? notes, double amount, String fromUser, String toUser, String groupID, String? token) async {

    if (token == null) {
      return null;
    }

    try {

      final requestBody = {
        'amount': amount,
        if (notes != null) 'notes': notes,
        'groupId' : groupID,
        'fromUser' : fromUser,
        'toUser' : toUser,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/group/$groupID/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Transaction.fromJson(json);
      } else {
        print('Create transaction failed: ${response.statusCode} - ${response.body}');
        return null;
      }

    } catch (e) {
      print('Create transaction failed: $e');
      return null;
    }

  }

  Future<bool> removeTransactionFromGroup(String groupID, String transactionID, String? token) async {
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/group/$groupID/transactions/$transactionID'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to remove transaction: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception while removing transaction: $e');
      return false;
    }
  }

  Future<List<Transaction>> fetchTransactionsByGroupID(String groupID, String? token) async {

    if(token == null) {
      return [];
    }

    try {

      final response = await http.get(
        Uri.parse('$baseUrl/api/group/$groupID/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.trim() == "null") {
          return [];
        }
        final List<dynamic> data = json.decode(response.body);
        return data.map((transaction) => Transaction.fromJson(transaction)).toList();
      } else {
        print('Failed to fetch transactions: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }

  }

  Future<bool> removeExpenseFromGroup(String groupID, String expenseID, String? token) async {
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/group/$groupID/expenses/$expenseID'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to remove expense: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception while removing expense: $e');
      return false;
    }
  }

  Future<Expense?> createExpense(Expense newExpense, String groupID, String? token) async {

    if (token == null) {
      return null;
    }

    try {
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/group/$groupID/expenses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(newExpense.toJson()),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Expense.fromJson(json);
      } else {
        print('Create group failed: ${response.statusCode} - ${response.body}');
        return null;
      }

    } catch (e) {
      print('Create group failed: $e');
      return null;
    }

  }

  Future<List<Expense>> fetchExpensesByGroupID(String groupID, String? token) async {

    if(token == null) {
      return [];
    }

    try {

      final response = await http.get(
        Uri.parse('$baseUrl/api/group/$groupID/expenses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.trim() == "null") {
          return [];
        }
        final List<dynamic> data = json.decode(response.body);
        return data.map((expense) => Expense.fromJson(expense)).toList();
      } else {
        print('Failed to fetch expenses: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching expenses: $e');
      return [];
    }

  }

  Future<List<User>> fetchSearchSpace(String groupID, String? token) async {

    if (token == null) {
      return [];
    }

    try {
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/group/$groupID/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.trim() == "null") {
          return [];
        }
        final List<dynamic> data = json.decode(response.body);
        return data.map((user) => User.fromJson(user)).toList();
      } else {
        print('Failed to fetch users: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }

  }

  Future<User?> addMemberToGroup(String groupID, String memberID, String? token) async {

    if (token == null) {
      return null;
    }

    try {

      final response = await http.post(
        Uri.parse('$baseUrl/api/group/$groupID/member'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id': memberID,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        print('Failed to add member: ${response.body}');
        return null;
      }

    } catch (e) {
      print('Exception while adding member: $e');
      return null;
    }

  }

  Future<bool> removeMemberFromGroup(String groupID, String memberID, String? token) async {
  if (token == null) return false;

  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/group/$groupID/member/$memberID'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to remove member: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Exception while removing member: $e');
    return false;
  }
}

  Future<GroupDetailed?> getGroupById(String groupID, String? token) async {

    if (token == null) {
      return null;
    }

    try {
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/group/$groupID'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return GroupDetailed.fromJson(data);
      } else {
        print('Failed to load group: ${response.statusCode}');
        return null;
      }

    } catch (e) {
      print('Failed to load group: $e');
      return null;
    }

  }

  Future<Group?> createGroup(String name, String? description, String? token) async {

    if (token == null) {
      return null;
    }

    try {

      final requestBody = {
        'name': name,
        if (description != null) 'description': description,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/group'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Group.fromJson(json);
      } else {
        print('Create group failed: ${response.statusCode} - ${response.body}');
        return null;
      }

    } catch (e) {
      print('Create group failed: $e');
      return null;
    }

  }

  Future<List<Group>?> fetchGroups(String? token) async {

    if (token == null) {
      return null;
    }

    try {
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/groups'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.trim() == "null") {
          return [];
        }
        final List data = jsonDecode(response.body);
        return data.map((json) => Group.fromJson(json)).toList();
      } else {
        return null;
      }

    } catch (e) {
      return null;
    }

  }

  Future<Map<String, dynamic>?> login(String email, String password) async {

    try {

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode != 200){
        return null;
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;

    } catch (e) {

      print("Verify Failed : $e");
      return null;

    }

  }

  Future<Map<String, dynamic>?> signup(String name, String email, String password) async {

    try {
      
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData;

    } catch (e) {

      print("Verify Failed : $e");
      return null;

    }

  }

  Future<bool> verify(String token) async {

    try {

      final response = await http.get(

        Uri.parse('$baseUrl/api/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }

      );

      return response.statusCode == 200;

    } catch (e) {

      print("Verify Failed : $e");
      return false;

    }

  }

}
