import 'package:flutter/material.dart';

class OnboardingQuestionPage extends StatelessWidget {
  final String question;
  final String subtitle;
  final List<String> options;
  final VoidCallback onOptionSelected; // Função para pular de página

  const OnboardingQuestionPage({
    super.key,
    required this.question,
    required this.subtitle,
    required this.options,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Image.network('https://i.imgur.com/lwgH7H5.png', height: 80),
        const SizedBox(height: 20),
        Text(
          question,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFF7941D), fontSize: 16),
        ),
        const SizedBox(height: 40),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F8F8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                return _buildButton(options[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        onPressed: onOptionSelected, // Ao clicar, executa a função de mudar página
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black54,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}