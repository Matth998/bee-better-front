import 'dart:convert';
import 'package:bee_better_flutter/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user_session.dart';

class AuthService {
  static const String baseUrl = AppConfig.baseUrl;

  // ─── SALVAR SESSÃO NO CACHE ───────────────────────────────────────────────
  static Future<void> _salvarSessaoCache({
    required String token,
    required int id,
    required String nome,
    required String email,
    required String birthDate,
    required String fotoPerfil,
    required int nivel,
    required int moedas,
    required int experiencia,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setInt('id', id);
    await prefs.setString('nome', nome);
    await prefs.setString('email', email);
    await prefs.setString('birthDate', birthDate);
    await prefs.setString('fotoPerfil', fotoPerfil);
    await prefs.setInt('nivel', nivel);
    await prefs.setInt('moedas', moedas);
    await prefs.setInt('experiencia', experiencia);
  }

  // ─── RESTAURAR SESSÃO DO CACHE ────────────────────────────────────────────
  static Future<bool> restaurarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) return false;

    UserSession.token = token;
    UserSession.id = prefs.getInt('id') ?? 0;
    UserSession.nome = prefs.getString('nome') ?? '';
    UserSession.email = prefs.getString('email') ?? '';
    UserSession.dataNascimento = prefs.getString('birthDate') ?? '';
    UserSession.fotoPerfil = prefs.getString('fotoPerfil') ?? '';
    UserSession.nivel = prefs.getInt('nivel') ?? 1;
    UserSession.moedas = prefs.getInt('moedas') ?? 0;
    UserSession.experiencia = prefs.getInt('experiencia') ?? 0;

    return true;
  }

  // ─── LOGOUT ───────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    UserSession.token = '';
    UserSession.id = 0;
    UserSession.nome = '';
    UserSession.email = '';
    UserSession.dataNascimento = '';
    UserSession.fotoPerfil = '';
    UserSession.nivel = 1;
    UserSession.moedas = 0;
    UserSession.experiencia = 0;
    UserSession.firstLoginToday = false;
  }

  // ─── LOGIN ────────────────────────────────────────────────────────────────
  static Future<void> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': senha}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];

      final token = data['token'] ?? '';
      final id = user['id'] ?? 0;
      final nome = user['name'] ?? '';
      final emailUser = user['email'] ?? '';
      final birthDate = user['birth_date'] ?? '';
      final fotoPerfil = user['profilePictureUrl'] != null
          ? '$baseUrl${user['profilePictureUrl']}'
          : '';
      final nivel = user['mascot_level'] ?? 1;
      final moedas = user['coins'] ?? 0;
      final experiencia = user['mascot_experience'] ?? 0;

      UserSession.salvarSessao(
        token: token,
        id: id,
        nome: nome,
        email: emailUser,
        birthDate: birthDate,
        fotoPerfil: fotoPerfil,
        nivel: nivel,
        moedas: moedas,
        experiencia: experiencia,
      );

      // Persiste no cache para manter logado
      await _salvarSessaoCache(
        token: token,
        id: id,
        nome: nome,
        email: emailUser,
        birthDate: birthDate,
        fotoPerfil: fotoPerfil,
        nivel: nivel,
        moedas: moedas,
        experiencia: experiencia,
      );

      // Daily login não bloqueia o fluxo principal
      try {
        await registrarDailyLoginPublic();
      } catch (e) {
        print('Daily login falhou mas ignorando: $e');
      }
    } else {
      throw Exception('Usuário ou senha inválidos');
    }
  }

  // ─── REGISTER ─────────────────────────────────────────────────────────────
  static Future<void> register(
      String usuario,
      String email,
      String senha,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': usuario, 'email': email, 'password': senha}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final user = data['user'];

      final token = data['token'] ?? '';
      final id = user['id'] ?? 0;
      final nome = user['name'] ?? '';
      final emailUser = user['email'] ?? '';
      final birthDate = user['birth_date'] ?? '';
      final fotoPerfil = user['profilePictureUrl'] != null
          ? '$baseUrl${user['profilePictureUrl']}'
          : '';
      final nivel = user['mascot_level'] ?? 1;
      final moedas = user['coins'] ?? 0;
      final experiencia = user['mascot_experience'] ?? 0;

      UserSession.salvarSessao(
        token: token,
        id: id,
        nome: nome,
        email: emailUser,
        birthDate: birthDate,
        fotoPerfil: fotoPerfil,
        nivel: nivel,
        moedas: moedas,
        experiencia: experiencia,
      );

      // Persiste no cache para manter logado
      await _salvarSessaoCache(
        token: token,
        id: id,
        nome: nome,
        email: emailUser,
        birthDate: birthDate,
        fotoPerfil: fotoPerfil,
        nivel: nivel,
        moedas: moedas,
        experiencia: experiencia,
      );

      // Daily login não bloqueia o fluxo principal
      try {
        await registrarDailyLoginPublic();
      } catch (e) {
        print('Daily login falhou mas ignorando: $e');
      }
    } else {
      throw Exception('Erro ao criar conta. Tente novamente.');
    }
  }

  // ─── DAILY LOGIN ──────────────────────────────────────────────────────────
  static Future<void> registrarDailyLoginPublic() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/${UserSession.id}/daily-login'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final firstLogin = data['firstLoginToday'] ?? false;
        UserSession.moedas = data['coins'] ?? UserSession.moedas;
        UserSession.firstLoginToday = firstLogin;

        // Atualiza moedas no cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('moedas', UserSession.moedas);
      }
    } catch (e) {
      print('Erro ao registrar daily login: $e');
    }
  }
}