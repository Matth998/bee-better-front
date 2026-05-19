import 'dart:math';
import 'package:flutter/material.dart';

class CloakroomScreen extends StatefulWidget {
  const CloakroomScreen({super.key});

  @override
  State<CloakroomScreen> createState() => _CloakroomScreenState();
}

class _CloakroomScreenState extends State<CloakroomScreen>
    with TickerProviderStateMixin {
  // ── Animação das asas (frame-by-frame) ──
  late AnimationController _wingController;
  final List<String> _wingFrames = [
    'assets/images/abelha_asa_fechada.png',
    'assets/images/abelha_asa_abrindo.png',
    'assets/images/abelha_asa_aberta.png',
    'assets/images/abelha_asa_abrindo.png',
  ];
  int _currentFrame = 0;

  // ── Animação de hover (subir/descer) ──
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  final List<Map<String, dynamic>> _items = List.generate(
    8,
        (i) => {'nome': 'Item ${i + 1}', 'asset': null, 'equipado': false},
  );

  @override
  void initState() {
    super.initState();

    // Asas
    _wingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _startWingAnimation();

    // Hover: sobe e desce suavemente em loop
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _hoverAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  void _startWingAnimation() {
    Future.doWhile(() async {
      if (!mounted) return false;
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return false;
      setState(() {
        _currentFrame = (_currentFrame + 1) % _wingFrames.length;
      });
      return true;
    });
  }

  @override
  void dispose() {
    _wingController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final corpoWidth = size.width * 0.45;
    final asaWidth = size.width * 0.25;

    // Sombra: posicionada abaixo da abelha
    // Quando abelha sobe (offset negativo) → sombra menor
    // Quando abelha desce (offset positivo) → sombra maior
    const shadowBaseWidth = 60.0;
    const hoverRange = 20.0; // total de variação (10 + 10)

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── FUNDO + ABELHA ──
          Positioned.fill(
            child: Stack(
              children: [
                // Fundo
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/vestiario_fundo.png',
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                  ),
                ),

                // Botão voltar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7941D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),

                // Abelha + sombra animadas
                AnimatedBuilder(
                  animation: _hoverAnimation,
                  builder: (context, child) {
                    final offset = _hoverAnimation.value; // -10 a +10
                    // Normaliza 0..1 onde 0 = mais alto, 1 = mais baixo
                    final t = (offset + 10) / hoverRange;
                    // Sombra: menor quando abelha está em cima, maior quando está embaixo
                    final shadowScale = 0.6 + (t * 0.4); // 0.6 a 1.0
                    final shadowOpacity = 0.15 + (t * 0.2); // 0.15 a 0.35

                    return Align(
                      alignment: const Alignment(0, -0.3),
                      child: SizedBox(
                        width: corpoWidth,
                        height: corpoWidth + 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // SOMBRA — posição fixa, só escala
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Transform.scale(
                                  scaleX: shadowScale,
                                  scaleY: shadowScale * 0.4,
                                  child: Opacity(
                                    opacity: shadowOpacity,
                                    child: Image.asset(
                                      'assets/images/sombra_abelha.png',
                                      width: shadowBaseWidth,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ABELHA — sobe e desce com offset
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Transform.translate(
                                offset: Offset(0, offset),
                                child: Center(
                                  child: SizedBox(
                                    width: corpoWidth,
                                    height: corpoWidth,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Asa atrás
                                        Positioned(
                                          top: 0,
                                          left: (corpoWidth - asaWidth) / 2,
                                          child: SizedBox(
                                            width: asaWidth,
                                            height: asaWidth,
                                            child: Image.asset(
                                              _wingFrames[_currentFrame],
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        // Corpo na frente
                                        Image.asset(
                                          'assets/images/abelha_corpo.png',
                                          width: corpoWidth,
                                          fit: BoxFit.contain,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // ── SHEET DE ITENS ──
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.15,
            maxChildSize: 0.90,
            snap: true,
            snapSizes: const [0.15, 0.45, 0.90],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 16),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: _items.isEmpty
                          ? const Center(
                        child: Text(
                          'Nenhum item ainda.\nVisite a loja!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black38,
                            fontSize: 15,
                          ),
                        ),
                      )
                          : GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: _items.length,
                        itemBuilder: (_, index) =>
                            _buildItemCard(_items[index]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final equipado = item['equipado'] as bool;
    final asset = item['asset'] as String?;

    return GestureDetector(
      onTap: () {
        setState(() {
          for (final i in _items) {
            i['equipado'] = false;
          }
          item['equipado'] = !equipado;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color:
          equipado ? const Color(0xFFFFF3CD) : const Color(0xFFF5F0E8),
          borderRadius: BorderRadius.circular(16),
          border: equipado
              ? Border.all(color: const Color(0xFFF7941D), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: asset != null
              ? Image.asset(
            asset,
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          )
              : Icon(
            Icons.star_outline,
            color: equipado
                ? const Color(0xFFF7941D)
                : Colors.black12,
            size: 36,
          ),
        ),
      ),
    );
  }
}