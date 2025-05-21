import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  final String baseUrl = 'http://localhost:8080';

  Future<bool> login(String email, String password) async {

    final reponse = await http.post(

      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),

    );

    return reponse.statusCode == 200;

  }

  Future<bool> signup(String name, String email, String password) async {

    final response = await http.post(

      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),

    );

    return response.statusCode == 200;

  }

}