import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  final String baseUrl = 'http://localhost:8080';

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
