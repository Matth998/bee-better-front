import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:flutter/material.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // Fases: inspire, segure, expire
  final List<Map<String, dynamic>> phases = [
    {'label': 'Inspire', 'seconds': 4, 'scale': 1.2},
    {'label': 'Segure', 'seconds': 7, 'scale': 1.2},
    {'label': 'Expire', 'seconds': 8, 'scale': 0.8},
  ];

  int currentPhase = 0;
  int secondsLeft = 4;
  bool running = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _start() {
    setState(() {
      running = true;
      currentPhase = 0;
      secondsLeft = phases[0]['seconds'];
    });
    _runPhase();
  }

  void _stop() {
    _controller.stop();
    _controller.reset();
    setState(() {
      running = false;
      currentPhase = 0;
      secondsLeft = phases[0]['seconds'];
    });
  }

  Future<void> _runPhase() async {
    if (!mounted || !running) return;

    final phase = phases[currentPhase];
    final duration = Duration(seconds: phase['seconds'] as int);
    final targetScale = phase['scale'] as double;

    // Anima o círculo
    _controller.duration = duration;
    if (targetScale > 1.0) {
      _scaleAnimation = Tween<double>(begin: _scaleAnimation.value, end: 1.2)
          .animate(CurvedAnimation(
          parent: _controller, curve: Curves.easeInOut));
      _controller.forward(from: 0);
    } else {
      _scaleAnimation = Tween<double>(begin: 1.2, end: 0.8).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward(from: 0);
    }

    // Countdown
    for (int i = phase['seconds'] as int; i > 0; i--) {
      if (!mounted || !running) return;
      setState(() => secondsLeft = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted || !running) return;

    // Próxima fase
    setState(() {
      currentPhase = (currentPhase + 1) % phases.length;
      secondsLeft = phases[currentPhase]['seconds'];
    });

    _runPhase();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phase = phases[currentPhase];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9C4),
      body: SafeArea(
        child: Column(
          children: [
            // BOTÃO VOLTAR
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7941D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chevron_left,
                        color: Colors.white),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // CÍRCULO ANIMADO
            GestureDetector(
              onTap: running ? _stop : _start,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: running ? _scaleAnimation.value : 1.0,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFF7941D),
                            const Color(0xFFF7941D).withOpacity(0.3),
                            Colors.transparent,
                          ],
                          stops: const [0.4, 0.7, 1.0],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          running
                              ? phase['label'] as String
                              : 'Toque para\niniciar',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // CONTADOR
            if (running)
              Text(
                '$secondsLeft',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF7941D),
                ),
              ),

            const SizedBox(height: 12),

            // FASES
            if (running)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(phases.length, (i) {
                  return Container(
                    width: i == currentPhase ? 20 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i == currentPhase
                          ? const Color(0xFFF7941D)
                          : Colors.orange.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

            const SizedBox(height: 12),

            // DESCRIÇÃO DA TÉCNICA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                running
                    ? _getPhaseDescription(currentPhase)
                    : 'Técnica 4-7-8\nInspire por 4s • Segure por 7s • Expire por 8s',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black45,
                  height: 1.5,
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 3,
        onTap: (index) {
          if (index == 4) Navigator.pushNamed(context, '/home');
          if (index == 0) Navigator.pushNamed(context, '/alarms');
          if (index == 1) Navigator.pushNamed(context, '/calendar');
        },
      ),
    );
  }

  String _getPhaseDescription(int phase) {
    switch (phase) {
      case 0:
        return 'Inspire lentamente pelo nariz...';
      case 1:
        return 'Segure o ar com calma...';
      case 2:
        return 'Expire lentamente pela boca...';
      default:
        return '';
    }
  }
}