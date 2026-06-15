import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final loginUrl = 'http://localhost:3000/api/auth/login';
  try {
    final loginRes = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': 'admin@gmail.com', // Assuming an admin or test user exists
        'password': 'password123'
      }),
    );
    final loginData = jsonDecode(loginRes.body);
    final token = loginData['token'];
    
    if (token == null) {
      print('Failed to login: $loginData');
      return;
    }

    final url = 'http://localhost:3000/api/marketplace/vouchers';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch(e) {
    print('Error: $e');
  }
}
