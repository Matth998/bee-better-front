import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://localhost:8080';

  // LOGIN
  static Future<Map<String, dynamic>> login(String usuario, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': usuario,
        'password': senha,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Usuário ou senha inválidos');
    }
  }

  // REGISTER
  static Future<void> register(String usuario, String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': usuario,
        'email': email,
        'password': senha,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao criar conta. Tente novamente.');
    }
  }
}