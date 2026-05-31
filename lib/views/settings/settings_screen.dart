import 'package:bee_better_flutter/constants.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:bee_better_flutter/services/user_session.dart';
import 'package:bee_better_flutter/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Permissões
  bool _notificacoes = false;
  bool _alarmes = false;
  bool _segundoPlano = false;
  bool _armazenamento = false;
  bool _bateria = false;
  bool _otimizacaoBateria = false;

  // Experiência
  bool _ativarNotificacoes = false;
  bool _ativarLembretes = false;
  String _tipoComemoracao = 'animado';

  // Período de atividade
  int _horaAcorda = 6;
  int _minutoAcorda = 0;
  int _horaDorme = 23;
  int _minutoDorme = 0;

  // Modo descanso ← adicionado
  int _horaDescansoInicio = 23;
  int _minutoDescansoInicio = 0;
  int _horaDescansoFim = 8;
  int _minutoDescansoFim = 0;

  static const String _baseUrl = AppConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadPreferences();
  }

  Future<void> _checkPermissions() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    final notification = await Permission.notification.status;
    final storage = await Permission.storage.status;
    setState(() {
      _notificacoes = notification.isGranted;
      _armazenamento = storage.isGranted;
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ativarNotificacoes = prefs.getBool('ativar_notificacoes') ?? false;
      _ativarLembretes = prefs.getBool('ativar_lembretes') ?? false;
      _horaAcorda = prefs.getInt('hora_acorda') ?? 6;
      _minutoAcorda = prefs.getInt('minuto_acorda') ?? 0;
      _horaDorme = prefs.getInt('hora_dorme') ?? 23;
      _minutoDorme = prefs.getInt('minuto_dorme') ?? 0;
      _horaDescansoInicio = prefs.getInt('hora_descanso_inicio') ?? 23;
      _minutoDescansoInicio = prefs.getInt('minuto_descanso_inicio') ?? 0;
      _horaDescansoFim = prefs.getInt('hora_descanso_fim') ?? 8;
      _minutoDescansoFim = prefs.getInt('minuto_descanso_fim') ?? 0;
      _tipoComemoracao = prefs.getString('tipo_comemoracao') ?? 'animado';
    });
  }

  Future<void> _sairDaConta() async {
    final confirm = await _showConfirmDialog(
      'Sair da conta',
      'Deseja realmente sair da sua conta?',
    );
    if (!confirm) return;

    await AuthService.logout();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _savePeriodoAtividade() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hora_acorda', _horaAcorda);
    await prefs.setInt('minuto_acorda', _minutoAcorda);
    await prefs.setInt('hora_dorme', _horaDorme);
    await prefs.setInt('minuto_dorme', _minutoDorme);
  }

  Future<void> _saveModoDescanso() async {
    // Salva localmente
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hora_descanso_inicio', _horaDescansoInicio);
    await prefs.setInt('minuto_descanso_inicio', _minutoDescansoInicio);
    await prefs.setInt('hora_descanso_fim', _horaDescansoFim);
    await prefs.setInt('minuto_descanso_fim', _minutoDescansoFim);

    // Envia para o backend
    try {
      final sleepTime =
          '${_horaDescansoInicio.toString().padLeft(2, '0')}:${_minutoDescansoInicio.toString().padLeft(2, '0')}:00';
      final wakeTime =
          '${_horaDescansoFim.toString().padLeft(2, '0')}:${_minutoDescansoFim.toString().padLeft(2, '0')}:00';

      await http.patch(
        Uri.parse('$_baseUrl/daily-progress/user/${UserSession.id}/sleep'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${UserSession.token}',
        },
        body: jsonEncode({
          'sleepTime': sleepTime,
          'wakeTime': wakeTime,
        }),
      );
    } catch (e) {
      debugPrint('Erro ao salvar sono: $e');
    }
  }

  String _formatTime(int hora, int minuto) {
    return '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';
  }

  void _abrirComemoracao() {
    String tempComemoracao = _tipoComemoracao; // Salva o estado atual

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ocupa apenas o tamanho do conteúdo
                children: [
                  // Indicador visual de arraste
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Área de seleção com os dois cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // --- Opção ESTÁTICO ---
                      _buildOptionCard(
                        title: 'Estático',
                        imagePath: 'assets/images/comemoracao_estatico.png',
                        isSelected: tempComemoracao == 'estatico',
                        onTap: () => setModalState(() => tempComemoracao = 'estatico'),
                      ),

                      // --- Opção ANIMADO ---
                      _buildOptionCard(
                        title: 'Animado',
                        imagePath: 'assets/images/comemoracao_animado.png',
                        isSelected: tempComemoracao == 'animado',
                        onTap: () => setModalState(() => tempComemoracao = 'animado'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Botão "Selecionar" (Salvar)
                  ElevatedButton(
                    onPressed: () async {
                      // 1. Atualiza o estado da tela principal
                      setState(() {
                        _tipoComemoracao = tempComemoracao;
                      });
                      // 2. Salva a escolha no SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('tipo_comemoracao', tempComemoracao);
                      // 3. Fecha o modal
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7941D), // Cor Laranja do Bee Better
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Selecionar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }
// Widget auxiliar para construir os cards de opção com borda dinâmica
  Widget _buildOptionCard({
    required String title,
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFFF7941D) : Colors.grey.shade300,
                width: isSelected ? 2.5 : 1.0,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              // Fallback temporário caso a imagem ainda não exista no projeto
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.celebration,
                size: 50,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _abrirPeriodoAtividade() {
    int tempHoraAcorda = _horaAcorda;
    int tempMinutoAcorda = _minutoAcorda;
    int tempHoraDorme = _horaDorme;
    int tempMinutoDorme = _minutoDorme;

    final horaAcordaController =
    FixedExtentScrollController(initialItem: _horaAcorda);
    final minutoAcordaController =
    FixedExtentScrollController(initialItem: _minutoAcorda);
    final horaDormeController =
    FixedExtentScrollController(initialItem: _horaDorme);
    final minutoDormeController =
    FixedExtentScrollController(initialItem: _minutoDorme);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Período de atividade',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text(
                    'Selecione o período em que você acorda até a hora de dormir',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Hora que você acorda',
                            style: TextStyle(fontSize: 13)),
                        GestureDetector(
                          onTap: () => _abrirSeletorHora(
                            context: context,
                            horaInicial: tempHoraAcorda,
                            minutoInicial: tempMinutoAcorda,
                            horaController: horaAcordaController,
                            minutoController: minutoAcordaController,
                            onConfirm: (h, m) => setModalState(() {
                              tempHoraAcorda = h;
                              tempMinutoAcorda = m;
                            }),
                          ),
                          child: Row(children: [
                            Text(_formatTime(tempHoraAcorda, tempMinutoAcorda),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            const Icon(Icons.expand_more,
                                size: 16, color: Colors.black45),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Hora que você dorme',
                            style: TextStyle(fontSize: 13)),
                        GestureDetector(
                          onTap: () => _abrirSeletorHora(
                            context: context,
                            horaInicial: tempHoraDorme,
                            minutoInicial: tempMinutoDorme,
                            horaController: horaDormeController,
                            minutoController: minutoDormeController,
                            onConfirm: (h, m) => setModalState(() {
                              tempHoraDorme = h;
                              tempMinutoDorme = m;
                            }),
                          ),
                          child: Row(children: [
                            Text(_formatTime(tempHoraDorme, tempMinutoDorme),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            const Icon(Icons.expand_more,
                                size: 16, color: Colors.black45),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _horaAcorda = tempHoraAcorda;
                          _minutoAcorda = tempMinutoAcorda;
                          _horaDorme = tempHoraDorme;
                          _minutoDorme = tempMinutoDorme;
                        });
                        _savePeriodoAtividade();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7941D),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Salvar',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ← MODO DESCANSO adicionado
  void _abrirModoDescanso() {
    int tempHoraInicio = _horaDescansoInicio;
    int tempMinutoInicio = _minutoDescansoInicio;
    int tempHoraFim = _horaDescansoFim;
    int tempMinutoFim = _minutoDescansoFim;

    final horaInicioController =
    FixedExtentScrollController(initialItem: _horaDescansoInicio);
    final minutoInicioController =
    FixedExtentScrollController(initialItem: _minutoDescansoInicio);
    final horaFimController =
    FixedExtentScrollController(initialItem: _horaDescansoFim);
    final minutoFimController =
    FixedExtentScrollController(initialItem: _minutoDescansoFim);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Modo descanso',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text(
                    'Selecione o período em que você não quer receber notificações',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('De:', style: TextStyle(fontSize: 13)),
                        GestureDetector(
                          onTap: () => _abrirSeletorHora(
                            context: context,
                            horaInicial: tempHoraInicio,
                            minutoInicial: tempMinutoInicio,
                            horaController: horaInicioController,
                            minutoController: minutoInicioController,
                            onConfirm: (h, m) => setModalState(() {
                              tempHoraInicio = h;
                              tempMinutoInicio = m;
                            }),
                          ),
                          child: Row(children: [
                            Text(_formatTime(tempHoraInicio, tempMinutoInicio),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            const Icon(Icons.expand_more,
                                size: 16, color: Colors.black45),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Até:', style: TextStyle(fontSize: 13)),
                        GestureDetector(
                          onTap: () => _abrirSeletorHora(
                            context: context,
                            horaInicial: tempHoraFim,
                            minutoInicial: tempMinutoFim,
                            horaController: horaFimController,
                            minutoController: minutoFimController,
                            onConfirm: (h, m) => setModalState(() {
                              tempHoraFim = h;
                              tempMinutoFim = m;
                            }),
                          ),
                          child: Row(children: [
                            Text(_formatTime(tempHoraFim, tempMinutoFim),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            const Icon(Icons.expand_more,
                                size: 16, color: Colors.black45),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _horaDescansoInicio = tempHoraInicio;
                          _minutoDescansoInicio = tempMinutoInicio;
                          _horaDescansoFim = tempHoraFim;
                          _minutoDescansoFim = tempMinutoFim;
                        });
                        _saveModoDescanso();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7941D),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Salvar',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _abrirSeletorHora({
    required BuildContext context,
    required int horaInicial,
    required int minutoInicial,
    required FixedExtentScrollController horaController,
    required FixedExtentScrollController minutoController,
    required Function(int, int) onConfirm,
  }) {
    int selectedHora = horaInicial;
    int selectedMinuto = minutoInicial;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: 320,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          child: ListWheelScrollView.useDelegate(
                            controller: horaController,
                            itemExtent: 44,
                            perspective: 0.005,
                            diameterRatio: 1.5,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (i) =>
                                setModalState(() => selectedHora = i),
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 24,
                              builder: (_, i) {
                                final sel = i == selectedHora;
                                return Center(
                                  child: Text(
                                    i.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: sel ? 32 : 20,
                                      fontWeight: sel
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: sel
                                          ? Colors.black
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const Text(':',
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold)),
                        SizedBox(
                          width: 70,
                          child: ListWheelScrollView.useDelegate(
                            controller: minutoController,
                            itemExtent: 44,
                            perspective: 0.005,
                            diameterRatio: 1.5,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (i) =>
                                setModalState(() => selectedMinuto = i),
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 60,
                              builder: (_, i) {
                                final sel = i == selectedMinuto;
                                return Center(
                                  child: Text(
                                    i.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: sel ? 32 : 20,
                                      fontWeight: sel
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: sel
                                          ? Colors.black
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton(
                      onPressed: () {
                        onConfirm(selectedHora, selectedMinuto);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7941D),
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('OK',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _limparCache() async {
    final confirm = await _showConfirmDialog(
      'Limpar cache',
      'Isso vai apagar todos os dados do app e deslogar sua conta. Deseja continuar?',
    );
    if (!confirm) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  Future<void> _restaurarConfiguracoes() async {
    final confirm = await _showConfirmDialog(
      'Restaurar configurações',
      'Isso vai restaurar todas as configurações do app para o padrão. Deseja continuar?',
    );
    if (!confirm) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ativar_notificacoes');
    await prefs.remove('ativar_lembretes');
    await prefs.remove('hora_acorda');
    await prefs.remove('minuto_acorda');
    await prefs.remove('hora_dorme');
    await prefs.remove('minuto_dorme');
    await prefs.remove('hora_descanso_inicio');
    await prefs.remove('minuto_descanso_inicio');
    await prefs.remove('hora_descanso_fim');
    await prefs.remove('minuto_descanso_fim');
    setState(() {
      _ativarNotificacoes = false;
      _ativarLembretes = false;
      _horaAcorda = 6;
      _minutoAcorda = 0;
      _horaDorme = 23;
      _minutoDorme = 0;
      _horaDescansoInicio = 23;
      _minutoDescansoInicio = 0;
      _horaDescansoFim = 8;
      _minutoDescansoFim = 0;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurações restauradas!'),
          backgroundColor: Color(0xFFF7941D),
        ),
      );
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7941D)),
            child: const Text('Confirmar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7941D),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.chevron_left,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('CONFIGURAÇÕES DO APP'),
                        const SizedBox(height: 8),
                        _buildCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Permissões'),
                              _buildPermissionTile('Permitir notificações',
                                  _notificacoes, () => openAppSettings()),
                              _buildPermissionTile(
                                  'Permitir alarmes em segundo plano',
                                  _alarmes,
                                      () => openAppSettings()),
                              _buildPermissionTile(
                                  'Permitir execução em segundo plano',
                                  _segundoPlano,
                                      () => openAppSettings()),
                              _buildPermissionTile(
                                  'Permitir acesso ao armazenamento',
                                  _armazenamento,
                                      () => openAppSettings()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Bateria'),
                              _buildPermissionTile(
                                  'Permitir execução em segundo plano',
                                  _bateria,
                                      () => openAppSettings()),
                              _buildPermissionTile(
                                  'Desativar otimização de bateria',
                                  _otimizacaoBateria,
                                      () => openAppSettings()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Dados'),
                              _buildActionTile('Limpar cache',
                                  color: const Color(0xFFFFD100),
                                  onTap: _limparCache),
                              _buildActionTile(
                                  'Restaurar configurações padrão',
                                  color: const Color(0xFFFFD100),
                                  onTap: _restaurarConfiguracoes),
                              _buildActionTile('Sair da conta',
                                  color: Colors.redAccent,
                                  onTap: _sairDaConta),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader('EXPERIÊNCIA DO APP'),
                        const SizedBox(height: 8),
                        _buildCard(
                          child: Column(
                            children: [
                              _buildSwitchTile('Ativar notificações',
                                  _ativarNotificacoes, (val) {
                                    setState(() => _ativarNotificacoes = val);
                                    _savePreference('ativar_notificacoes', val);
                                  }),
                              _buildSwitchTile(
                                  'Ativar lembretes', _ativarLembretes,
                                      (val) {
                                    setState(() => _ativarLembretes = val);
                                    _savePreference('ativar_lembretes', val);
                                  }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCard(
                          child: Column(
                            children: [
                              _buildNavTile(
                                'Comemoração',
                                'Escolha a forma de comemorar suas vitórias',
                                onTap: _abrirComemoracao,
                              ),
                              _buildNavTile(
                                'Período de atividade',
                                'Selecione o período em que você acorda até a hora de dormir',
                                onTap: _abrirPeriodoAtividade,
                              ),
                              _buildNavTile(
                                'Adicionar widget',
                                'Adicione um widget a sua tela para ter os seus companheiros mais próximos',
                                trailing: const Icon(Icons.add,
                                    color: Colors.black54),
                                onTap: () {},
                              ),
                              _buildNavTile(
                                'Modo descanso',
                                'Selecione o período em que você não quer receber notificações',
                                onTap: _abrirModoDescanso, // ← conectado
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.5)),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
        ],
      ),
      child: child,
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget _buildPermissionTile(
      String title, bool value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black87))),
          Switch(
            value: value,
            onChanged: (_) => onTap(),
            activeColor: const Color(0xFFF7941D),
            inactiveThumbColor: Colors.black45,
            inactiveTrackColor: Colors.black12,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 13, color: Colors.black87)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFF7941D),
            inactiveThumbColor: Colors.black45,
            inactiveTrackColor: Colors.black12,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title,
      {required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13, color: Colors.black87)),
            Container(
              width: 40,
              height: 22,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile(String title, String subtitle,
      {Widget? trailing, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black45)),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}