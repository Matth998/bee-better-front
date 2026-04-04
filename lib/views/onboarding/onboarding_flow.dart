import 'package:bee_better_flutter/views/onboarding/onboarding_multi_select.dart';
import 'package:flutter/material.dart';
import 'onboarding_question_page.dart'; // Importa o molde que criado
import 'location_selector.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  // O controlador que manda a página ir para frente
  final PageController _pageController = PageController();

  void _nextPage() {
    // Se não for a última página, vai para a próxima
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF1B8),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Impede o usuário de arrastar (obriga a clicar)
        children: [
          // TELA 1
          OnboardingQuestionPage(
            question: "Quantos anos você tem?",
            subtitle: "Isso nos ajuda a melhorar a sua experiência",
            options: ["Menos de 18", "18-25", "26-30", "31-40", "41-50", "51+"],
            onOptionSelected: _nextPage,
          ),
          // TELA 2
          OnboardingQuestionPage(
            question: "Qual o seu gênero?",
            subtitle: "Isso nos ajuda a melhorar a sua experiência",
            options: ["Homem Cis", "Mulher Cis", "Homem Trans", "Mulher trans", "Não Binário", "Outro"],
            onOptionSelected: _nextPage,
          ),
          // TELA 3
          LocationSelector(onNext: _nextPage),
          // TELA 4
          OnboardingQuestionPage(
            question: "Você tem TDAH?",
            subtitle: "Isso nos ajuda a melhorar a sua experiência",
            options: ["Sim, laudado", "Sim, sem laudo", "Acredito que sim", "Não"],
            onOptionSelected: _nextPage,
          ),
          // TELA 5: MÚLTIPLA ESCOLHA
          MultiSelectQuestionPage(
            question: "Você tem algum dos citados abaixo?",
            subtitle: "Isso nos ajuda a melhorar a sua experiência",
            options: ["Transtorno do Espectro Autista (TEA)", "Transtorno Afetivo Bipolar (TAB)", "Transtorno do Estresse Pós-Traumático (TEPT)", "Ansiedade", "Depressão", "Outro"],
            onOptionSelected: _nextPage,
          ),
          // TELA 6
          OnboardingQuestionPage(
            question: "Você é estudante, trabalha, ambos ou nenhum?",
            subtitle: "Isso nos ajuda a melhorar a sua experiência",
            options: ["Apenas estudo", "Apenas trabalho", "Ambos", "Nenhum"],
            onOptionSelected: _nextPage,
          ),
          MultiSelectQuestionPage(
            question: "Qual(is) dos sintomas mais te afeta(m)?",
            subtitle: "Isso nos ajuda a melhorar a sua experiência",
            options: ["Falta de foco", "Esquecimento", "Falta de organização", "Dificuldade com gerenciamento do tempo", "Impulsividade"],
            onOptionSelected: () {
              // Mandando para a pág pós onboarding - Loading
              Navigator.pushReplacementNamed(context, '/pos_onboarding');
            },
          ),
        ],
      ),
    );
  }
}