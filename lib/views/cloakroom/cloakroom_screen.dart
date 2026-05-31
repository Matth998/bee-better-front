import 'dart:convert';
import 'package:bee_better_flutter/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bee_better_flutter/services/user_session.dart';

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

  // ── Estado ──
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  static const String _baseUrl = AppConfig.baseUrl;

  @override
  void initState() {
    super.initState();

    _wingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _startWingAnimation();

    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _hoverAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/shop/user/${UserSession.id}/items'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _items = data.map((item) => <String, dynamic>{
            'id': item['id'],
            'shopItemId': item['shop_item_id'],
            'nome': item['name'],
            'asset': item['asset_name'],
            'category': item['category'],
            'price': item['price'] ?? 0,
            'equipado': item['equipped'] ?? false,
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar inventário: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleEquipItem(Map<String, dynamic> item) async {
    final int userItemId = item['id'] as int;
    final String nome = item['nome'] as String;

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/shop/user/${UserSession.id}/equip/$userItemId'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );

      if (response.statusCode == 200) {
        await _fetchInventory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$nome equipado!'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao equipar item: $e');
    }
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
    const shadowBaseWidth = 60.0;
    const hoverRange = 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── FUNDO + ABELHA ─────────────────────────────────────────────
          Positioned.fill(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/vestiario_fundo.png',
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                  ),
                ),
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
                        child: const Icon(Icons.chevron_left,
                            color: Colors.white, size: 26),
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _hoverAnimation,
                  builder: (context, child) {
                    final offset = _hoverAnimation.value;
                    final t = (offset + 10) / hoverRange;
                    final shadowScale = 0.6 + (t * 0.4);
                    final shadowOpacity = 0.15 + (t * 0.2);

                    return Align(
                      alignment: const Alignment(0, -0.3),
                      child: SizedBox(
                        width: corpoWidth,
                        height: corpoWidth + 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Sombra
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

                            // Abelha (corpo + asas)
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
                                        // ── Asas ──────────────────────
                                        Positioned(
                                          left: (corpoWidth - asaWidth) / 2 - 20,
                                          top: 0,
                                          child: Transform.translate(
                                            offset: const Offset(0, -0.7),
                                            child: SizedBox(
                                              width: asaWidth,
                                              height: asaWidth,
                                              child: Image.asset(
                                                _wingFrames[_currentFrame],
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // ── Corpo ──────────────────────
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

          // ── SHEET DE ITENS ─────────────────────────────────────────────
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
                child: ListView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    _loading
                        ? const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFF7941D)),
                      ),
                    )
                        : _items.isEmpty
                        ? const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          'Nenhum item ainda.',
                          style: TextStyle(
                              color: Colors.black38, fontSize: 15),
                        ),
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics:
                        const NeverScrollableScrollPhysics(),
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
    final isPadrao = (item['price'] as int? ?? 0) == 0;

    return GestureDetector(
      onTap: () => _toggleEquipItem(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: equipado
              ? const Color(0xFFFFF3CD)
              : const Color(0xFFF5F0E8),
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
        child: Stack(
          children: [
            Center(
              child: asset != null
                  ? Image.asset(
                'assets/images/shop/$asset.png',
                width: 52,
                height: 52,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.inventory,
                  color: Colors.black26,
                  size: 32,
                ),
              )
                  : const Icon(Icons.star_outline,
                  color: Colors.black12, size: 36),
            ),

            // Badge "Padrão"
            if (isPadrao)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Padrão',
                    style: TextStyle(fontSize: 7, color: Colors.black54),
                  ),
                ),
              ),

            // Badge equipado
            if (equipado)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7941D),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      color: Colors.white, size: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }
}