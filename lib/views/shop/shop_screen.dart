import 'dart:convert';
import 'dart:math';
import 'package:bee_better_flutter/constants.dart';
import 'package:bee_better_flutter/services/user_session.dart';
import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final List<String> frases = [
    'Tenho itens novos todos os dias!',
    'Venha! Dê uma olhada!',
    'Estava me perguntando quando você viria visitar minha loja!',
    'Eu sabia que você gostaria de mudar um pouco!',
    'Acho que tenho exatamente o que você precisa!',
    'Quando o mel é bom, a abelha sempre volta!',
  ];

  late String fraseAtual;
  List<Map<String, dynamic>> dailyItems = [];
  bool loading = true;

  static const String _baseUrl = AppConfig.baseUrl;

  static const List<String> _assetspadrao = [
    'coroa_padrao',
    'abelha_corpo_padrao',
    'abelha_asas_padrao',
    'colmeia_padrao',
    'rainha_corpo_padrao',
    'rainha_asas_padrao',
  ];

  @override
  void initState() {
    super.initState();
    fraseAtual = frases[Random().nextInt(frases.length)];
    _fetchDailyShop();
  }

  Future<void> _fetchDailyShop() async {
    setState(() => loading = true);
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/shop/user/${UserSession.id}/daily'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          dailyItems = data
              .map((item) => {
            'id': item['id'],
            'name': item['name'],
            'description': item['description'],
            'price': item['price'],
            'assetName': item['asset_name'],
            'category': item['category'],
          })
              .where((item) => !_assetspadrao.contains(item['assetName']))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar loja diária: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _comprarItem(Map<String, dynamic> item) async {
    if (UserSession.moedas < (item['price'] as int)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.fixed,
            backgroundColor: Colors.redAccent,
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Moedas insuficientes para comprar ${item['name']}!',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(item['name'],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/shop/${item['assetName']}.png',
              height: 80,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.image_not_supported,
                size: 60,
                color: Colors.black26,
              ),
            ),
            const SizedBox(height: 12),
            Text(item['description'] ?? ''),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.circle, color: Color(0xFFFFD100), size: 18),
                const SizedBox(width: 6),
                Text(
                  '${item['price']} moedas',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF7941D),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Comprar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.post(
        Uri.parse(
            '$_baseUrl/shop/user/${UserSession.id}/purchase/${item['id']}'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          UserSession.moedas -= (item['price'] as int);
          dailyItems.removeWhere((i) => i['id'] == item['id']);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item['name']} comprado!'),
              backgroundColor: const Color(0xFFF7941D),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Erro ao comprar item'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao comprar item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // Tenda: 604x461 → proporção height/width = 0.763
    final tendaH = w * 1.35;

    // Caixa: 144x155 → proporção height/width = 1.076
    // 4 caixas por linha com gap entre elas
    const int cols = 4;
    const double gapH = 3.0; // gap horizontal entre caixas
    const double gapV = 6.0; // gap vertical entre linhas
    const double paddingH = 4.0; // padding lateral da grade
    final caixaW = (w - paddingH * 2 - gapH * (cols - 1)) / cols;
    final caixaH = caixaW * (155 / 144); // mantém proporção original

    // Grade começa logo abaixo da tenda
    final gradeTop = tendaH;
    // Altura total da grade: 2 linhas + gap + padding
    final gradeH = caixaH * 2 + gapV + 16;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF1B8),
      body: SafeArea(
        child: Stack(
          children: [
            // ── FUNDO AMARELO (ocupa tudo atrás) ─────────────────────────
            Positioned.fill(
              child: Container(color: const Color(0xFFFDF1B8)),
            ),

            // ── TENDA (topo, largura total) ───────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/tenda.png',
                width: w,
                height: tendaH,
                fit: BoxFit.fill,
              ),
            ),

            Positioned(
              top: tendaH,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(color: const Color(0xFFFDF1B8)),
            ),

            // ── APICULTOR (entre tenda e caixas) ─────────────────────────
            Positioned(
              top: tendaH * 0.456,
              right: w * 0.04,
              child: Image.asset(
                'assets/images/apicultor.png',
                height: tendaH * 0.60,
              ),
            ),

            // ── BALÃO DE FALA ─────────────────────────────────────────────
            Positioned(
              top: tendaH * 0.52,
              left: w * 0.04,
              width: w * 0.50,
              child: CustomPaint(
                painter: _SpeechBubblePainter(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14, 10, 14, w * 0.10),
                  child: Text(
                    fraseAtual,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: w * 0.030,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),

            // ── GRADE DE CAIXAS ───────────────────────────────────────────
            Positioned(
              top: gradeTop,
              left: 0,
              right: 0,
              height: gradeH,
              child: loading
                  ? const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFFF7941D)),
              )
                  : Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: paddingH),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── LINHA 1 ───────────────────────────────────
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: List.generate(cols, (i) {
                        final item = i < dailyItems.length
                            ? dailyItems[i]
                            : null;
                        return _buildCaixa(
                            item, caixaW, caixaH);
                      }),
                    ),

                    const SizedBox(height: gapV),

                    // ── LINHA 2 ───────────────────────────────────
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: List.generate(cols, (i) {
                        final idx = i + cols;
                        final item = idx < dailyItems.length
                            ? dailyItems[idx]
                            : null;
                        return _buildCaixa(
                            item, caixaW, caixaH);
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // ── MOEDAS ────────────────────────────────────────────────────
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5A2B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${UserSession.moedas}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.circle,
                        color: Color(0xFFFFD100), size: 16),
                  ],
                ),
              ),
            ),

            // ── BOTÃO VOLTAR ──────────────────────────────────────────────
            Positioned(
              top: 12,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7941D),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chevron_left, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 4,
        onTap: (index) {
          if (index == 4) Navigator.pushNamed(context, '/home');
          if (index == 0) Navigator.pushNamed(context, '/alarms');
          if (index == 1) Navigator.pushNamed(context, '/calendar');
          if (index == 3) Navigator.pushNamed(context, '/featuresScreen');
        },
      ),
    );
  }

  Widget _buildCaixa(
      Map<String, dynamic>? item, double caixaW, double caixaH) {
    return GestureDetector(
      onTap: item != null ? () => _comprarItem(item) : null,
      child: SizedBox(
        width: caixaW,
        height: caixaH,
        child: Stack(
          children: [
            // Imagem da caixa como fundo
            Positioned.fill(
              child: Image.asset(
                'assets/images/caixa.png',
                fit: BoxFit.fill,
              ),
            ),

            // Conteúdo do item por cima
            if (item != null)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Imagem do item (ocupa ~60% da caixa)
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          caixaW * 0.08,
                          caixaH * 0.06,
                          caixaW * 0.08,
                          0),
                      child: Image.asset(
                        'assets/images/shop/${item['assetName']}.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          color: Colors.white38,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // Nome
                  Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: caixaW * 0.05),
                    child: Text(
                      item['name'],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFFFDF1B8),
                        fontSize: caixaW * 0.11,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 2)
                        ],
                      ),
                    ),
                  ),

                  // Preço
                  Padding(
                    padding: EdgeInsets.only(bottom: caixaH * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.circle,
                            color: Color(0xFFFFD100), size: 8),
                        const SizedBox(width: 2),
                        Text(
                          '${item['price']}',
                          style: TextStyle(
                            color: const Color(0xFFFFD100),
                            fontSize: caixaW * 0.11,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(color: Colors.black54, blurRadius: 2)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    const radius = 16.0;
    final tailHeight = size.height * 0.28;
    final bubbleHeight = size.height - tailHeight;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, bubbleHeight),
        const Radius.circular(radius),
      ));

    final tailPath = Path()
      ..moveTo(size.width * 0.80, bubbleHeight)
      ..lineTo(size.width * 0.95, bubbleHeight)
      ..lineTo(size.width * 0.95, bubbleHeight + tailHeight)
      ..close();

    path.addPath(tailPath, Offset.zero);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}