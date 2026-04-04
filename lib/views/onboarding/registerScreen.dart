import 'package:flutter/material.dart';

const Color appBackgroundColor = Color(0xFFFDF1B8);
const Color appPrimaryOrange = Color(0xFFF7941D);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers para capturar os dados
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      // AppBar simples apenas com o botão de voltar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Text(
                'Cadastro',
                style: TextStyle(fontSize: 48, color: Colors.black),
              ),
              const SizedBox(height: 20),
              Center(
                child: Image.network(
                  'https://i.imgur.com/zbBifE3.png',
                  height: 100,
                ),
              ),
              const SizedBox(height: 40),

              // Campo Usuário
              _buildInput(
                controller: _userController,
                hint: 'Usuário',
                icon: Icons.person,
              ),
              const SizedBox(height: 15),

              // Campo E-mail
              _buildInput(
                controller: _emailController,
                hint: 'E-mail',
                icon: Icons.email,
              ),
              const SizedBox(height: 15),

              // Campo Senha
              _buildInput(
                controller: _passwordController,
                hint: 'Senha',
                icon: Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 15),

              // Campo Repetir Senha
              _buildInput(
                controller: _confirmPasswordController,
                hint: 'Repetir senha',
                icon: Icons.lock,
                isPassword: true,
              ),

              const SizedBox(height: 40),

              // Botão Criar Conta
              ElevatedButton(
                onPressed: () {
                  // 1. Aqui colocaráemos a lógica de salvar no banco de dados.
                  // 2. Se o salvamento der certo, chamamos a tela de transição:

                  Navigator.pushReplacementNamed(context, '/pre_onboarding');

                  print(
                    "Usuário cadastrado! Indo para a introdução do onboarding...",
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appPrimaryOrange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 12.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Criar conta',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para não repetir código de estilo dos inputs
  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(
          0xFFF8F8F8,
        ),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
        ),
      ),
    );
  }
}
