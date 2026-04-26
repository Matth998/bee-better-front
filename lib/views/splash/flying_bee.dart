import 'package:flutter/material.dart';
import 'dart:math';

class FlyingBee extends StatefulWidget {
  const FlyingBee({super.key});

  @override
  State<FlyingBee> createState() => _FlyingBeeState();
}

class _FlyingBeeState extends State<FlyingBee> with SingleTickerProviderStateMixin {
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
      duration: Duration(seconds: _random.nextInt(8) + 8), // Tempo de animação
    )..repeat(reverse: true);

    // Ouve a direção da animação para espelhar a abelha
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

    _moveX = Tween<double>(
      begin: 0,
      end: screenWidth - 40, // atravessar a tela toda
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _startTop,
          left: _moveX.value,
          child: Transform.scale(
            scaleX: _facingRight ? 1 : -1, // Espelha a abelha ao voltar
            child: Image.asset(
              'assets/images/abelha.png',
              height: 25,
            ),
          ),
        );
      },
    );
  }
}