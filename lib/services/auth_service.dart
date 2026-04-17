import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8080';

  // LOGIN
  static Future<void> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': senha,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];
      print('RESPONSE COMPLETO: ${response.body}');

      UserSession.salvarSessao(
        token: data['token'] ?? '',
        id: user['id'] ?? 0,
        nome: user['name'] ?? '',
        email: user['email'] ?? '',
        dataNascimento: user['dataNascimento'] ?? '',
        fotoPerfil: user['fotoPerfil'] ?? '',
        pontuacao: user['pontuacao'] ?? 0,
        nivel: user['nivel'] ?? 0,
        moedas: user['moedas'] ?? 0,
      );
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