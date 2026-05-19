import 'dart:math';
import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    fraseAtual = frases[Random().nextInt(frases.length)];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final lojaWidth = size.width;
    final lojaAlturaReal = lojaWidth * (750 / 600);
    final lojaHeight =
    lojaAlturaReal > size.height ? lojaAlturaReal : size.height;

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
                  padding: EdgeInsets.fromLTRB(
                      14, 10, 14, lojaWidth * 0.12),
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
                  child:
                  const Icon(Icons.chevron_left, color: Colors.white),
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

    // RABINHO EMBAIXO À DIREITA
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