import 'package:flutter/material.dart';
import 'dart:math';

// ─── ABELHA WORKER (corpo + asas) ────────────────────────────────────────────
class FlyingBee extends StatefulWidget {
  /// Asset do corpo equipado (ex: 'abelha_corpo_vermelho')
  /// Se null, usa o padrão
  final String? corpoAsset;

  /// Asset das asas equipadas (ex: 'abelha_asas_azul')
  /// Se null, usa o padrão
  final String? asasAsset;

  const FlyingBee({
    super.key,
    this.corpoAsset,
    this.asasAsset,
  });

  @override
  State<FlyingBee> createState() => _FlyingBeeState();
}

class _FlyingBeeState extends State<FlyingBee>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _moveX;

  final _random = Random();
  late double _startTop;
  bool _facingRight = true;

  @override
  void initState() {
    super.initState();
    _startTop = _random.nextDouble() * 150 + 20;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _random.nextInt(8) + 8),
    )..repeat(reverse: true);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.reverse) {
        setState(() => _facingRight = false);
      } else if (status == AnimationStatus.forward) {
        setState(() => _facingRight = true);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenWidth = MediaQuery.of(context).size.width;
    _moveX = Tween<double>(begin: 0, end: screenWidth - 40)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Frame da abelha worker: 25x17 → proporção h/w = 0.68
    const double beeW = 25.0;
    const double beeH = 17.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _startTop,
          left: _moveX.value,
          child: Transform.scale(
            scaleX: _facingRight ? 1 : -1,
            child: _WorkerBeeWidget(
              width: beeW,
              height: beeH,
              corpoAsset: widget.corpoAsset ?? 'abelha_corpo_padrao',
              asasAsset: widget.asasAsset ?? 'abelha_asas_padrao',
            ),
          ),
        );
      },
    );
  }
}

// ─── ABELHA RAINHA (corpo + asas + coroa) ────────────────────────────────────
class QueenBee extends StatefulWidget {
  /// Asset do corpo equipado (ex: 'rainha_corpo_rosa')
  final String? corpoAsset;

  /// Asset das asas equipadas (ex: 'rainha_asas_azul')
  final String? asasAsset;

  /// Asset da coroa/chapéu equipado (ex: 'coroa_padrao')
  final String? coroa;

  const QueenBee({
    super.key,
    this.corpoAsset,
    this.asasAsset,
    this.coroa,
  });

  @override
  State<QueenBee> createState() => _QueenBeeState();
}

class _QueenBeeState extends State<QueenBee>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _moveX;

  final _random = Random();
  late double _startTop;
  bool _facingRight = true;

  @override
  void initState() {
    super.initState();
    _startTop = _random.nextDouble() * 100 + 40;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _random.nextInt(6) + 10),
    )..repeat(reverse: true);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.reverse) {
        setState(() => _facingRight = false);
      } else if (status == AnimationStatus.forward) {
        setState(() => _facingRight = true);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenWidth = MediaQuery.of(context).size.width;
    _moveX = Tween<double>(begin: 20, end: screenWidth - 60)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Frame da rainha: 59x47 → proporção h/w = 0.7966
    const double queenW = 59.0;
    const double queenH = 47.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _startTop,
          left: _moveX.value,
          child: Transform.scale(
            scaleX: _facingRight ? 1 : -1,
            child: _QueenBeeWidget(
              width: queenW,
              height: queenH,
              corpoAsset: widget.corpoAsset ?? 'rainha_corpo_padrao',
              asasAsset: widget.asasAsset ?? 'rainha_asas_padrao',
              coroa: widget.coroa ?? 'coroa_padrao',
            ),
          ),
        );
      },
    );
  }
}

// ─── WIDGET INTERNO: WORKER ───────────────────────────────────────────────────
// Frame 25x17 — proporções calculadas dos assets originais
class _WorkerBeeWidget extends StatelessWidget {
  final double width;
  final double height;
  final String corpoAsset;
  final String asasAsset;

  const _WorkerBeeWidget({
    required this.width,
    required this.height,
    required this.corpoAsset,
    required this.asasAsset,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Asas (atrás, topo esquerdo)
          Positioned(
            left: width * 0.19,
            top: height * -0.1,
            width: width * 0.360,
            height: height * 0.706,
            child: Image.asset(
              'assets/images/shop/$asasAsset.png',
              fit: BoxFit.fill,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          // 2. Corpo (na frente)
          Positioned(
            left: width * 0.040,
            top: height * 0.353,
            width: width * 0.920,
            height: height * 0.647,
            child: Image.asset(
              'assets/images/shop/$corpoAsset.png',
              fit: BoxFit.fill,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── WIDGET INTERNO: RAINHA ───────────────────────────────────────────────────
// Frame 59x47 — proporções calculadas dos assets originais
class _QueenBeeWidget extends StatelessWidget {
  final double width;
  final double height;
  final String corpoAsset;
  final String asasAsset;
  final String coroa;

  const _QueenBeeWidget({
    required this.width,
    required this.height,
    required this.corpoAsset,
    required this.asasAsset,
    required this.coroa,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Asas (atrás do corpo)
          Positioned(
            left: width * 0.15,
            top: height * 0.07,
            width: width * 0.390,
            height: height * 0.596,
            child: Image.asset(
              'assets/images/shop/$asasAsset.png',
              fit: BoxFit.fill,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          // 2. Corpo (na frente das asas)
          Positioned(
            left: 0,
            top: height * 0.447,
            width: width,
            height: height * 0.553,
            child: Image.asset(
              'assets/images/shop/$corpoAsset.png',
              fit: BoxFit.fill,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          // 3. Coroa (no topo)
          Positioned(
            left: width * 0.55,
            top: height * 0.37,
            width: width * 0.186,
            height: height * 0.170,
            child: Image.asset(
              'assets/images/shop/$coroa.png',
              fit: BoxFit.fill,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}