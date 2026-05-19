import 'package:bee_better_flutter/services/user_session.dart';
import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:bee_better_flutter/views/splash/flying_bee.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Mostra streak bonus se for primeiro login do dia
      if (UserSession.firstLoginToday) {
        UserSession.firstLoginToday = false; // reseta para não mostrar de novo
        _mostrarStreakBonus();
        // Pequeno delay para o snackbar aparecer antes do modal
        await Future.delayed(const Duration(milliseconds: 600));
      }

      // 2. Mostra modal de humor se ainda não respondeu hoje
      await _verificarHumor();
    });
  }

  // ── Streak bonus ──

  void _mostrarStreakBonus() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.local_fire_department, color: Color(0xFFFFD100)),
            SizedBox(width: 8),
            Text(
              '+5 moedas! Streak do dia! 🔥',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF3D2B1F),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ── Humor ──

  Future<void> _verificarHumor() async {
    final prefs = await SharedPreferences.getInstance();
    final ultimaData = prefs.getString('ultima_data_humor');
    final hoje = DateTime.now().toIso8601String().substring(0, 10);

    if (ultimaData != hoje) {
      _mostrarModalHumor();
    }
  }

  Future<void> _mostrarModalHumor() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _HumorModal(
        onSelected: (humor) async {
          final prefs = await SharedPreferences.getInstance();
          final hoje = DateTime.now().toIso8601String().substring(0, 10);
          await prefs.setString('ultima_data_humor', hoje);
          await _salvarHumor(humor);
        },
      ),
    );
  }

  Future<void> _salvarHumor(String humor) async {
    try {
      await http.post(
        Uri.parse(
            'http://localhost:8080/daily-progress/mood/${UserSession.id}?mood=$humor'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );
    } catch (e) {
      print('Erro ao salvar humor: $e');
    }
  }

  void _navegarEAtualizar(String rota) async {
    await Navigator.pushNamed(context, rota);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int userLevel = UserSession.nivel > 0 ? UserSession.nivel : 1;
    int userCoins = UserSession.moedas;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFCDE7F7)),
          Positioned.fill(
            child: Image.asset(
              'assets/images/Fundo_nuvens.png',
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.topCenter,
              fit: BoxFit.cover,
            ),
          ),

          ...List.generate(
              userLevel, (index) => FlyingBee(key: ValueKey(index))),

          const QueenBee(),

          Positioned(
            top: 60,
            right: 20,
            child: _buildCoinCounter(userCoins),
          ),

          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/galho.png',
              fit: BoxFit.fitHeight,
            ),
          ),

          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => _navegarEAtualizar('/cloakroom'),
              child: Image.asset('assets/images/colmeia.png', height: 120),
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.60,
            minChildSize: 0.15,
            maxChildSize: 0.90,
            snap: true,
            snapSizes: const [0.15, 0.45, 0.90],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Center(
                      child: Container(
                        margin:
                        const EdgeInsets.only(top: 10, bottom: 10),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20, bottom: 10),
                        child: FloatingActionButton.small(
                          onPressed: () {},
                          backgroundColor: Colors.white,
                          elevation: 2,
                          child: const Icon(Icons.add, color: Colors.black),
                        ),
                      ),
                    ),
                    _buildTaskItem(
                      "Metas para hoje",
                      onTap: () => _navegarEAtualizar('/goals/today'),
                    ),
                    _buildTaskItem(
                      "Metas em andamento",
                      onTap: () => _navegarEAtualizar('/goals/in-progress'),
                    ),
                    _buildTaskItem(
                      "Metas concluídas",
                      onTap: () => _navegarEAtualizar('/goals/completed'),
                    ),
                    _buildTaskItem(
                      "Missões",
                      onTap: () => _navegarEAtualizar('/goals/missions'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) _navegarEAtualizar('/alarms');
          if (index == 1) _navegarEAtualizar('/calendar');
          if (index == 3) _navegarEAtualizar('/featuresScreen');
          if (index == 5) _navegarEAtualizar('/menu');
        },
      ),
    );
  }

  Widget _buildCoinCounter(int coins) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 15),
          padding: const EdgeInsets.fromLTRB(25, 6, 12, 6),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5A2B),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                coins.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.circle, color: Color(0xFFFFD100), size: 18),
            ],
          ),
        ),
        Positioned(
          left: -50,
          top: -35,
          child: GestureDetector(
            onTap: () => _mostrarModalHumor(),
            child: Image.asset(
              'assets/images/solzinho_humor.png',
              height: 100,
              width: 100,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(String title, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.chevron_right, color: Colors.black),
          ],
        ),
      ),
    );
  }
}

// ── MODAL DE HUMOR ──
class _HumorModal extends StatelessWidget {
  final Function(String) onSelected;

  const _HumorModal({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final humores = [
      {
        'label': 'Péssimo',
        'image': 'assets/images/pessimo.png',
        'value': 'NEGATIVE'
      },
      {
        'label': 'Ruim',
        'image': 'assets/images/ruim.png',
        'value': 'NEGATIVE'
      },
      {
        'label': 'Neutro',
        'image': 'assets/images/neutro.png',
        'value': 'NEUTRAL'
      },
      {
        'label': 'Bom',
        'image': 'assets/images/bom.png',
        'value': 'POSITIVE'
      },
      {
        'label': 'Ótimo',
        'image': 'assets/images/otimo.png',
        'value': 'POSITIVE'
      },
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9C4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16),
                ),
              ),
            ),
            const Text(
              'Como está seu humor?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: humores.map((humor) {
                return GestureDetector(
                  onTap: () {
                    onSelected(humor['value']!);
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        humor['image']!,
                        width: 44,
                        height: 44,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        humor['label']!,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}