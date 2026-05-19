import 'package:bee_better_flutter/services/auth_service.dart';
import 'package:bee_better_flutter/services/user_session.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Color appBackgroundColor = Color(0xFFFDF1B8);
const Color appPrimaryOrange = Color(0xFFF7941D);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loadingGoogle = false;

  static const String _baseUrl = 'http://localhost:8080';

  // Google Sign In configurado com o client ID Android
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '666409812247-5ubt6sg7gge17m2usu4br3i5a47jekrs.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginComGoogle() async {
    setState(() => _loadingGoogle = true);
    try {
      // 1. Abre o seletor de conta Google
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        setState(() => _loadingGoogle = false);
        return; // usuário cancelou
      }

      // 2. Pega o token de autenticação
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        throw Exception('Não foi possível obter o token do Google');
      }

      // 3. Envia o token para o backend
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];

        UserSession.salvarSessao(
          token: data['token'] ?? '',
          id: user['id'] ?? 0,
          nome: user['name'] ?? '',
          email: user['email'] ?? '',
          birthDate: user['birth_date'] ?? '',
          fotoPerfil: user['profile_picture_url'] != null
              ? '$_baseUrl${user['profile_picture_url']}'
              : '',
          nivel: user['mascot_level'] ?? 1,
          moedas: user['coins'] ?? 0,
          experiencia: user['mascot_experience'] ?? 0,
        );

        await AuthService.registrarDailyLoginPublic();

        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else {
        throw Exception('Erro ao autenticar com Google');
      }
    } catch (e) {
      debugPrint('Erro Google Sign In: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao entrar com Google: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Image.asset(
                  'assets/images/abelha_login.png',
                  height: 120,
                ),
              ),
              const SizedBox(height: 50),

              // Campo usuário
              _buildInput(
                controller: _userController,
                hint: 'E-mail',
                icon: Icons.person,
              ),
              const SizedBox(height: 20),

              // Campo senha
              _buildInput(
                controller: _passwordController,
                hint: 'Senha',
                icon: Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 30),

              // Botão login
              ElevatedButton(
                onPressed: () async {
                  if (_userController.text.isNotEmpty &&
                      _passwordController.text.isNotEmpty) {
                    try {
                      await AuthService.login(
                        _userController.text,
                        _passwordController.text,
                      );
                      if (mounted) {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, preencha o e-mail e a senha.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appPrimaryOrange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 12.0,
                  ),
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 50),

              // Link cadastro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Não tem cadastro? ',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text(
                      'Crie sua conta',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Text(
                'ou entre com:',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Botões sociais
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google
                  _buildSocialButton(
                    imagePath: 'assets/images/google.jpg',
                    loading: _loadingGoogle,
                    onTap: _loginComGoogle,
                  ),
                  const SizedBox(width: 15),
                  // Instagram (em breve)
                  _buildSocialButton(
                    imagePath: 'assets/images/instagram.png',
                    onTap: () => _mostrarEmBreve('Instagram'),
                  ),
                  const SizedBox(width: 15),
                  // Facebook (em breve)
                  _buildSocialButton(
                    imagePath: 'assets/images/facebook.png',
                    onTap: () => _mostrarEmBreve('Facebook'),
                  ),
                  const SizedBox(width: 15),
                  // Twitter (em breve)
                  _buildSocialButton(
                    imagePath: 'assets/images/twitter.png',
                    onTap: () => _mostrarEmBreve('Twitter'),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarEmBreve(String rede) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login com $rede em breve!'),
        backgroundColor: const Color(0xFFF7941D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSocialButton({
    required String imagePath,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: ClipOval(
        child: Container(
          width: 45,
          height: 45,
          color: Colors.white,
          child: loading
              ? const Padding(
            padding: EdgeInsets.all(10),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFF7941D),
            ),
          )
              : Image.asset(imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
        ),
      ),
    );
  }
}