import 'dart:convert';
import 'dart:math';
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
    'Quando o mel é bom, a abelha sempre volta!'
  ];

  late String fraseAtual;
  List<Map<String, dynamic>> dailyItems = [];
  bool loading = true;

  static const String _baseUrl = 'http://localhost:8080';

  // Assets que são "padrão" e não precisam aparecer na loja
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
    // 1. VERIFICAÇÃO DE MOEDAS: Valida ANTES de abrir o diálogo de confirmação
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
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return; // Bloqueia a abertura do modal
    }

    // 2. Se ele tiver moedas, o fluxo segue normalmente para o diálogo
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            child:
            const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF7941D),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child:
            const Text('Comprar', style: TextStyle(color: Colors.white)),
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
    final lojaWidth = size.width;
    final lojaAlturaReal = lojaWidth * (750 / 600);
    final lojaHeight =
    lojaAlturaReal > size.height ? lojaAlturaReal : size.height;

    final boxAreaTop = lojaHeight * 0.535;
    final boxAreaHeight = lojaHeight - boxAreaTop;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF1B8),
      body: SafeArea(
        child: Stack(
          children: [
            // LOJA
            Positioned.fill(
              child: Image.asset(
                'assets/images/loja.png',
                width: lojaWidth,
                height: lojaHeight,
                fit: BoxFit.cover,
              ),
            ),

            // APICULTOR
            Positioned(
              bottom: lojaHeight * 0.365,
              right: lojaWidth * 0.04,
              child: Image.asset(
                'assets/images/apicultor.png',
                height: lojaHeight * 0.32,
              ),
            ),

            // BALÃO DE FALA
            Positioned(
              bottom: lojaHeight * 0.57,
              left: lojaWidth * 0.04,
              width: lojaWidth * 0.50,
              child: CustomPaint(
                painter: _SpeechBubblePainter(),
                child: Padding(
                  padding:
                  EdgeInsets.fromLTRB(14, 10, 14, lojaWidth * 0.12),
                  child: Text(
                    fraseAtual,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: lojaWidth * 0.030,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),

            // ── ITENS DIÁRIOS ──
            Positioned(
              top: boxAreaTop,
              left: 0,
              right: 0,
              height: boxAreaHeight,
              child: loading
                  ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFF7941D)),
              )
                  : dailyItems.isEmpty
                  ? const Center(
                child: Text(
                  'Todos os itens já são seus!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              )
                  : Container(
                alignment: Alignment.topCenter,
                height: boxAreaHeight,
                // Permite a rolagem horizontal da vitrine completa se faltar espaço
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: lojaWidth * 0.045,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FILEIRA DE CIMA (Itens nos índices 0, 1, 2, 3)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          for (int i = 0; i < dailyItems.length && i < 4; i++)
                            _buildItemCard(dailyItems[i], boxAreaHeight, lojaWidth),
                        ],
                      ),

                      // Espaçamento vertical exato entre a prateleira de cima e de baixo
                      SizedBox(height: boxAreaHeight * 0.045),

                      // FILEIRA DE BAIXO (Itens nos índices 4, 5, 6, 7)
                      if (dailyItems.length > 4)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            for (int i = 4; i < dailyItems.length && i < 8; i++)
                              _buildItemCard(dailyItems[i], boxAreaHeight, lojaWidth),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // MOEDAS
            Positioned(
              top: 16,
              right: 16,
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
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.circle,
                        color: Color(0xFFFFD100), size: 16),
                  ],
                ),
              ),
            ),

            // BOTÃO VOLTAR
            Positioned(
              top: 16,
              left: 16,
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

  Widget _buildItemCard(Map<String, dynamic> item, double boxAreaHeight, double lojaWidth) {
    // Retornando aos tamanhos fixos e proporcionais que mantêm as imagens pequenas e organizadas
    final cardWidth = lojaWidth * 0.205;
    final cardHeight = boxAreaHeight * 0.295;

    return GestureDetector(
      onTap: () => _comprarItem(item),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        // Margem lateral controlada para bater com as colunas do fundo
        margin: EdgeInsets.symmetric(horizontal: lojaWidth * 0.012),
        decoration: BoxDecoration(
          color: const Color(0xFF6B3F1A).withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFFD100).withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagem do item
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  'assets/images/shop/${item['assetName']}.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported,
                    color: Colors.white38,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Nome do item
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                item['name'],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 2),

            // Preço
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 2, right: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, color: Color(0xFFFFD100), size: 7),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      '${item['price']}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFFFD100),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
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