import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:bee_better_flutter/constants.dart';
import 'package:bee_better_flutter/views/pomodoro/pomodoro_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bee_better_flutter/services/user_session.dart';

// ─────────────────────────────────────────
// MODELO DE CONFIGURAÇÃO
// ─────────────────────────────────────────
class PomodoroConfig {
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int totalRounds;

  const PomodoroConfig({
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 30,
    this.totalRounds = 4,
  });
}

// ─────────────────────────────────────────
// ENUM DE MODO
// ─────────────────────────────────────────
enum PomodoroMode { pomodoro, shortBreak, longBreak, loop }

// ─────────────────────────────────────────
// TELA PRINCIPAL
// ─────────────────────────────────────────
class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with TickerProviderStateMixin {
  // Config
  PomodoroConfig config = const PomodoroConfig();

  // Estado do timer
  PomodoroMode _mode = PomodoroMode.pomodoro;
  bool _running = false;
  int _secondsLeft = 0;
  int _totalSeconds = 0;
  int _currentRound = 0;

  // Toque selecionado nas configurações
  String _ringtone = 'toque_4';

  // Sessão no back
  int? _sessionId;

  // Animação do arco
  late AnimationController _progressController;

  // Timer interno
  Timer? _timer;

  // Conexão back
  static const String _baseUrl = AppConfig.baseUrl;

  // ───── lifecycle ─────

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _resetTimer();
    _loadConfig();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  // ───── carregar configurações ─────

  Future<void> _loadConfig() async {
    final data = await PomodoroPrefs.load();
    final ringtoneLabel = data['ringtone'] as String;
    final ringtoneFile = 'toque_${ringtoneLabel.replaceAll('Toque ', '').trim()}';

    setState(() {
      _ringtone = ringtoneFile;
      config = PomodoroConfig(
        focusMinutes: data['focus'] as int,
        shortBreakMinutes: data['shortBreak'] as int,
        longBreakMinutes: data['longBreak'] as int,
      );
      // ← _resetTimer() inline aqui, dentro do setState
      _running = false;
      _totalSeconds = _durationForMode(_mode);
      _secondsLeft = _totalSeconds;
    });
    _timer?.cancel();
  }

  // ───── helpers ─────

  int _durationForMode(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.pomodoro:
        return config.focusMinutes * 60;
      case PomodoroMode.shortBreak:
        return config.shortBreakMinutes * 60;
      case PomodoroMode.longBreak:
        return config.longBreakMinutes * 60;
      case PomodoroMode.loop:
        return config.focusMinutes * 60;
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _totalSeconds = _durationForMode(_mode);
      _secondsLeft = _totalSeconds;
    });
  }

  void _setMode(PomodoroMode mode) {
    setState(() => _mode = mode);
    _resetTimer();
  }

  String get _timeLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress =>
      _totalSeconds > 0 ? 1 - (_secondsLeft / _totalSeconds) : 0;

  // ───── controles ─────

  Future<void> _startSession() async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/pomodoro/start'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${UserSession.token}',
        },
        body: jsonEncode({
          'userId': UserSession.id,
          'durationMinutes': _durationForMode(_mode) ~/ 60,
        }),
      );
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        _sessionId = data['id'];
      }
    } catch (e) {
      debugPrint('Erro ao iniciar sessão pomodoro: $e');
    }
  }

  Future<void> _finishSession() async {
    if (_sessionId == null) return;
    try {
      await http.patch(
        Uri.parse('$_baseUrl/pomodoro/$_sessionId/finish'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );
      _sessionId = null;
    } catch (e) {
      debugPrint('Erro ao finalizar sessão pomodoro: $e');
    }
  }

  void _togglePlay() {
    if (_running) {
      _pause();
    } else {
      _play();
    }
  }

  void _play() {
    if (_secondsLeft == 0) return;

    if (_mode == PomodoroMode.pomodoro || _mode == PomodoroMode.loop) {
      _startSession();
    }

    setState(() => _running = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _onTimerComplete();
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _onTimerComplete() {
    _timer?.cancel();
    setState(() => _running = false);

    // ── Toca o som ao finalizar ──────────────────────────────────────────
    final player = AudioPlayer();
    player.play(AssetSource('audio/$_ringtone.mp3')).catchError((e) {
      debugPrint('Erro ao tocar toque pomodoro: $e');
    });
    // Libera o player após 10 segundos
    Future.delayed(const Duration(seconds: 10), () => player.dispose());

    if (_mode == PomodoroMode.pomodoro || _mode == PomodoroMode.loop) {
      _finishSession();
      setState(() => _currentRound++);
    }

    // Auto-avança para próximo modo no loop
    if (_mode == PomodoroMode.loop) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _setMode(PomodoroMode.loop);
        _play();
      });
    }
  }

  void _restart() {
    _timer?.cancel();
    _sessionId = null;
    setState(() {
      _running = false;
      _secondsLeft = _totalSeconds;
      _currentRound = 0;
    });
  }

  // ───── build ─────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo_colmeia.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 8),
                _buildRoundCounter(),
                const Spacer(),
                _buildTimerCircle(size),
                const Spacer(),
                _buildControls(),
                const SizedBox(height: 24),
                _buildModeSelector(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF7941D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_left,
                  color: Colors.white, size: 28),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Cronômetro',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _openSettings,
            child: const Icon(Icons.settings, color: Colors.black54, size: 26),
          ),
        ],
      ),
    );
  }

  // ── Contador de rodadas ──
  Widget _buildRoundCounter() {
    return Text(
      '$_currentRound/${config.totalRounds}\nRodada',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        height: 1.3,
      ),
    );
  }

  // ── Círculo do timer ──
  Widget _buildTimerCircle(Size size) {
    final diameter = size.width * 0.72;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(diameter, diameter),
            painter: _ArcPainter(progress: _progress),
          ),
          Image.asset(
            'assets/images/abelha_login.png',
            width: diameter * 0.5,
            height: diameter * 0.5,
            errorBuilder: (_, __, ___) => _BeeIcon(size: diameter * 0.5),
          ),
          Positioned(
            bottom: diameter * 0.12,
            child: Text(
              _timeLabel,
              style: TextStyle(
                fontSize: diameter * 0.13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF7941D),
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Controles play / restart ──
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black26, width: 1.5),
            ),
            child: Icon(
              _running ? Icons.pause : Icons.play_arrow,
              color: Colors.black87,
              size: 30,
            ),
          ),
        ),
        const SizedBox(width: 32),
        GestureDetector(
          onTap: _restart,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black26, width: 1.5),
            ),
            child: const Icon(Icons.refresh, color: Colors.black87, size: 28),
          ),
        ),
      ],
    );
  }

  // ── Seletor de modo ──
  Widget _buildModeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              _modeButton('Pomodoro', PomodoroMode.pomodoro),
              const SizedBox(width: 10),
              _modeButton('Loop', PomodoroMode.loop),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _modeButton('Descanso curto', PomodoroMode.shortBreak),
              const SizedBox(width: 10),
              _modeButton('Descanso longo', PomodoroMode.longBreak),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeButton(String label, PomodoroMode mode) {
    final selected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color:
            selected ? const Color(0xFFF7941D) : const Color(0xFFFAE89A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/pomodoroSettings').then((_) {
      _loadConfig(); // ← recarrega config e toque ao voltar das configurações
    });
  }
}

// ─────────────────────────────────────────
// CUSTOM PAINTER — arco de progresso
// ─────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final double progress;

  const _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;

    final trackPaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = const Color(0xFFF7941D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;

      final dotAngle = -pi / 2 + (2 * pi * progress);
      final dotX = center.dx + radius * cos(dotAngle);
      final dotY = center.dy + radius * sin(dotAngle);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        progressPaint,
      );

      final dotPaint = Paint()..color = Colors.black;
      canvas.drawCircle(Offset(dotX, dotY), 7, dotPaint);
    } else {
      final dotPaint = Paint()..color = Colors.black;
      canvas.drawCircle(Offset(center.dx, center.dy - radius), 7, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────
// ABELHA FALLBACK
// ─────────────────────────────────────────
class _BeeIcon extends StatelessWidget {
  final double size;
  const _BeeIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BeePainter(),
    );
  }
}

class _BeePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.32;

    final bodyPaint = Paint()..color = const Color(0xFFF7941D);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, cy), width: r * 1.2, height: r * 1.6),
      bodyPaint,
    );

    final stripePaint = Paint()..color = Colors.black;
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
            cx - r * 0.6, cy - r * 0.3 + i * r * 0.35, r * 1.2, r * 0.15),
        stripePaint,
      );
    }

    final headPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(cx, cy - r * 0.9), r * 0.3, headPaint);

    final wingPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - r * 0.7, cy - r * 0.2),
          width: r * 0.8,
          height: r * 0.5),
      wingPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx + r * 0.7, cy - r * 0.2),
          width: r * 0.8,
          height: r * 0.5),
      wingPaint,
    );
  }

  @override
  bool shouldRepaint(_BeePainter old) => false;
}