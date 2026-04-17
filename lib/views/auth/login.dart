import 'package:bee_better_flutter/services/auth_service.dart';
import 'package:bee_better_flutter/services/user_session.dart';
import 'package:flutter/material.dart';

// Constante para a cor de fundo bege claro
const Color appBackgroundColor = Color(0xFFFDF1B8);
// Constante para o laranja do botão
const Color appPrimaryOrange = Color(0xFFF7941D);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              const SizedBox(height: 60), // Espaço no topo
              // Título "Login"
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight:
                      FontWeight.w400, // Colocar a fonte real - Ver com a Julia
                  color: Colors.black,
                  fontFamily:
                      'Roboto', // Colocar a fonte real - Ver com a Julia
                ),
              ),

              const SizedBox(height: 30),

              // Imagem da abelha
              Center(
                child: Image.network(
                  'https://i.imgur.com/zbBifE3.png',
                  height: 120, // Ajuste de tamanho
                ),
              ),

              const SizedBox(height: 50),

              // Campo de entrada do Usuário
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // Posição da sombra
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _userController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Colors.black54),
                    hintText: 'Usuário',
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none, // Remove a borda padrão do input
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Campo de entrada da Senha
              Container(
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
                  controller: _passwordController,
                  obscureText: true, // Para esconder a senha
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Colors.black54),
                    hintText: 'Senha',
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Botão de Login
              ElevatedButton(
                onPressed: () async {
                  if (_userController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                    try {
                      await AuthService.login(
                        _userController.text,
                        _passwordController.text,
                      );

                      print('Token recebido: ${UserSession.token}');

                      Navigator.pushReplacementNamed(context, '/home');

                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  } else {
                    // Exibe um aviso caso os campos estejam vazios
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Por favor, preencha o usuário e a senha.',
                        ),
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

              // Links de Cadastro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Não tem cadastro? ',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/cadastro');
                    },
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.zero, // Remove padding do botão de texto
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text(
                      'Crie sua conta',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        decoration: TextDecoration.underline, // Linha embaixo
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

              const SizedBox(height: 30),

              // Ícones de Login Social
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícone do Google
                  _buildSocialIcon('https://i.imgur.com/gE21EKw.jpeg'),
                  const SizedBox(width: 15),
                  // Ícone do Instagram
                  _buildSocialIcon('https://i.imgur.com/Y2xVFpa.png'),
                  const SizedBox(width: 15),
                  // Ícone do Facebook
                  _buildSocialIcon('https://i.imgur.com/LjiSdfk.png'),
                  const SizedBox(width: 15),
                  // Ícone do X (Twitter)
                  _buildSocialIcon('https://i.imgur.com/87p4MIa.png'),
                ],
              ),
              const SizedBox(height: 40), // Espaço inferior
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para criar os ícones sociais
  Widget _buildSocialIcon(String iconPath) {
    return Container(
      width: 45,
      height: 45,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(8.0), // Padding interno para a imagem
      child: Center(child: Image.network(iconPath, fit: BoxFit.contain)),
    );
  }
}
