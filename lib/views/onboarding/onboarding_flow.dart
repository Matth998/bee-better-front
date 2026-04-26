import 'dart:convert';

import 'package:bee_better_flutter/services/user_session.dart';
import 'package:bee_better_flutter/views/onboarding/onboarding_data.dart';
import 'package:bee_better_flutter/views/onboarding/onboarding_multi_select.dart';
import 'package:flutter/material.dart';
import 'onboarding_question_page.dart'; // Importa o molde que criado
import 'location_selector.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

DateTime? _birthDate;

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  // O controlador que manda a página ir para frente
  final PageController _pageController = PageController();
  final OnboardingData _data = OnboardingData(); // Guarda respostas do usuário

  void _nextPage() {
    // Se não for a última página, vai para a próxima
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitOnboarding() async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:8080/users/${UserSession.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${UserSession.token}',
        },
        body: jsonEncode(_data.toJson()),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erro ${response.statusCode}');
      }
      // ← Atualiza a sessão com os dados retornados pelo backend
      final json = jsonDecode(response.body);
      UserSession.dataNascimento = json['birth_date'] ?? '';
    } catch (e) {
      rethrow;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF1B8),
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Impede o usuário de arrastar (obriga a clicar)
        children: [
          // TELA 1 - Data de Nascimento
          Column(
            children: [
              const SizedBox(height: 60),
              Image.asset('assets/images/abelha_login.png', height: 80),
              const SizedBox(height: 20),
              const Text(
                "Qual é a sua data de nascimento?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Isso nos ajuda a melhorar a sua experiência",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFF7941D), fontSize: 16),
              ),
              const SizedBox(height: 40),

              // CONTAINER BRANCO ARREDONDADO (igual às outras telas)
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
                  child: Column(
                    children: [
                      // CAMPO DE DATA
                      GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            locale: const Locale('pt', 'BR'),
                          );
                          if (picked != null) {
                            setState(() => _data.birthDate = picked);
                            _nextPage();
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _data.birthDate == null
                                    ? "Selecione sua data"
                                    : DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_data.birthDate!),
                                style: TextStyle(
                                  fontSize: 17,
                                  color: _data.birthDate == null
                                      ? Colors.grey
                                      : Colors.black87,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // TELA 2
          OnboardingQuestionPage(
            question: "Qual o seu gênero?",
            subtitle: "Isso nos ajuda a melhorar a sua experiência",
            options: [
              "Homem Cis",
              "Mulher Cis",
              "Homem Trans",
              "Mulher trans",
              "Não Binário",
              "Outro",
            ],
            onOptionSelected: (value) {
              _data.gender = value;
              _nextPage();
            },
          ),
          // TELA 3
          LocationSelector(
            onNext: (state, city) {
              _data.state = state;
              _data.city = city;
              _nextPage();
            },
          ),
          // TELA 4
          OnboardingQuestionPage(
            question: "Você tem TDAH?",
            subtitle: "Isso nos ajuda a melhorar a sua experiência",
            options: [
              "Sim, laudado",
              "Sim, sem laudo",
              "Acredito que sim",
              "Não",
            ],
            onOptionSelected: (value) {
              _data.hasTdah = value;
              _nextPage();
            },
          ),
          // TELA 5: MÚLTIPLA ESCOLHA
          MultiSelectQuestionPage(
            question: "Você tem algum dos citados abaixo?",
            subtitle: "Isso nos ajuda a melhorar a sua experiência",
            options: [
              "Transtorno do Espectro Autista (TEA)",
              "Transtorno Afetivo Bipolar (TAB)",
              "Transtorno do Estresse Pós-Traumático (TEPT)",
              "Ansiedade",
              "Depressão",
              "Outro",
            ],
            onOptionSelected: (values) {
              _data.otherConditions = values;
              _nextPage();
            },
          ),
          // TELA 6
          OnboardingQuestionPage(
            question: "Você é estudante, trabalha, ambos ou nenhum?",
            subtitle: "Isso nos ajuda a melhorar a sua experiência",
            options: ["Apenas estudo", "Apenas trabalho", "Ambos", "Nenhum"],
            onOptionSelected: (value) {
              _data.occupation = value;
              _nextPage();
            },
          ),
          MultiSelectQuestionPage(
            question: "Qual(is) dos sintomas mais te afeta(m)?",
            subtitle: "Isso nos ajuda a melhorar a sua experiência",
            options: [
              "Falta de foco",
              "Esquecimento",
              "Falta de organização",
              "Dificuldade com gerenciamento do tempo",
              "Impulsividade",
            ],
            onOptionSelected: (values) {
              _data.symptoms = values;
              final future = _submitOnboarding();
              Navigator.pushReplacementNamed(
                context,
                '/pos_onboarding',
                arguments: future,
              );
            },
          ),
        ],
      ),
    );
  }
}
