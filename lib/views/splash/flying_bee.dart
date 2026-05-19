import 'package:flutter/material.dart';
import 'dart:math';

class FlyingBee extends StatefulWidget {
  const FlyingBee({super.key});

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _startTop,
          left: _moveX.value,
          child: Transform.scale(
            scaleX: _facingRight ? 1 : -1,
            child: Image.asset('assets/images/abelha.png', height: 25),
          ),
        );
      },
    );
  }
}

// ← ABELHA RAINHA
class QueenBee extends StatefulWidget {
  const QueenBee({super.key});

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
    // ← posição um pouco diferente das abelhas comuns
    _startTop = _random.nextDouble() * 100 + 40;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _random.nextInt(6) + 10), // ← mais lenta e majestosa
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _startTop,
          left: _moveX.value,
          child: Transform.scale(
            scaleX: _facingRight ? 1 : -1,
            child: Image.asset(
              'assets/images/abelha_rainha.png',
              height: 45, // ← maior que as comuns (25)
            ),
          ),
        );
      },
    );
  }
}