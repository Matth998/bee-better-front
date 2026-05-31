import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────
// CHAVES SharedPreferences
// ─────────────────────────────────────────
class PomodoroPrefs {
  static const String focusKey = 'pomodoro_focus';
  static const String shortBreakKey = 'pomodoro_short_break';
  static const String longBreakKey = 'pomodoro_long_break';
  static const String ringtoneKey = 'pomodoro_ringtone';
  static const String saveChangesKey = 'pomodoro_save_changes';

  static Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'focus': prefs.getInt(focusKey) ?? 25,
      'shortBreak': prefs.getInt(shortBreakKey) ?? 5,
      'longBreak': prefs.getInt(longBreakKey) ?? 30,
      'ringtone': prefs.getString(ringtoneKey) ?? 'Toque 4',
      'saveChanges': prefs.getBool(saveChangesKey) ?? true,
    };
  }

  static Future<void> save({
    required int focus,
    required int shortBreak,
    required int longBreak,
    required String ringtone,
    required bool saveChanges,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(focusKey, focus);
    await prefs.setInt(shortBreakKey, shortBreak);
    await prefs.setInt(longBreakKey, longBreak);
    await prefs.setString(ringtoneKey, ringtone);
    await prefs.setBool(saveChangesKey, saveChanges);
  }
}

// ─────────────────────────────────────────
// TELA DE CONFIGURAÇÕES
// ─────────────────────────────────────────
class PomodoroSettingsScreen extends StatefulWidget {
  const PomodoroSettingsScreen({super.key});

  @override
  State<PomodoroSettingsScreen> createState() => _PomodoroSettingsScreenState();
}

class _PomodoroSettingsScreenState extends State<PomodoroSettingsScreen> {
  // Durações
  int _focusMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 30;

  // Opções de duração por coluna
  final List<int> _focusOptions = [20, 25, 30];
  final List<int> _shortBreakOptions = [4, 5, 6];
  final List<int> _longBreakOptions = [25, 30, 5];

  // Toque
  String _selectedRingtone = 'Toque 4';
  final List<String> _ringtones = [
    'Toque 1',
    'Toque 2',
    'Toque 3',
    'Toque 4',
    'Toque 5',
  ];

  // Toggle salvar alterações
  bool _saveChanges = true;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final data = await PomodoroPrefs.load();
    setState(() {
      _focusMinutes = data['focus'];
      _shortBreakMinutes = data['shortBreak'];
      _longBreakMinutes = data['longBreak'];
      _selectedRingtone = data['ringtone'];
      _saveChanges = data['saveChanges'];
      _loading = false;
    });
  }

  Future<void> _savePrefs() async {
    await PomodoroPrefs.save(
      focus: _focusMinutes,
      shortBreak: _shortBreakMinutes,
      longBreak: _longBreakMinutes,
      ringtone: _selectedRingtone,
      saveChanges: _saveChanges,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // FUNDO COLMEIA
          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo_colmeia.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: _loading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF7941D),
              ),
            )
                : Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        _buildDurationCard(),
                        const SizedBox(height: 20),
                        _buildRingtoneCard(),
                      ],
                    ),
                  ),
                ),
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
              child: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'CONFIGURAÇÕES DO CRONÔMETRO',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          // Espaço para alinhar o título ao centro
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  // ── Card de duração ──
  Widget _buildDurationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Duração da sessão',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Toggle salvar alterações
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Salvar alterações',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Switch(
                value: _saveChanges,
                onChanged: (val) => setState(() => _saveChanges = val),
                activeColor: const Color(0xFFF7941D),
                inactiveThumbColor: Colors.black38,
                inactiveTrackColor: Colors.black12,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Colunas de seleção de duração
          Row(
            children: [
              _buildDurationColumn(
                label: 'Foco',
                options: _focusOptions,
                selected: _focusMinutes,
                onSelect: (v) => setState(() => _focusMinutes = v),
              ),
              _buildDivider(),
              _buildDurationColumn(
                label: 'Descanso curto',
                options: _shortBreakOptions,
                selected: _shortBreakMinutes,
                onSelect: (v) => setState(() => _shortBreakMinutes = v),
              ),
              _buildDivider(),
              _buildDurationColumn(
                label: 'Descanso longo',
                options: _longBreakOptions,
                selected: _longBreakMinutes,
                onSelect: (v) => setState(() => _longBreakMinutes = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 120,
      color: Colors.black12,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildDurationColumn({
    required String label,
    required List<int> options,
    required int selected,
    required ValueChanged<int> onSelect,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          ...options.map((opt) {
            final isSelected = opt == selected;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF7941D).withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: const Color(0xFFF7941D), width: 1.5)
                      : Border.all(color: Colors.transparent),
                ),
                child: Text(
                  '${opt.toString().padLeft(2, '0')} Min',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFFF7941D)
                        : Colors.black54,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Card de toque ──
  Widget _buildRingtoneCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cabeçalho toque
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Toque',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: _savePrefs,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7941D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Selecionar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lista de toques
          ..._ringtones.map((toque) {
            final isSelected = toque == _selectedRingtone;
            return GestureDetector(
              onTap: () => setState(() => _selectedRingtone = toque),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF7941D)
                      : const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.play_arrow,
                      color: isSelected ? Colors.white : Colors.black87,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        toque,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color:
                          isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.graphic_eq
                          : Icons.more_horiz,
                      color: isSelected
                          ? Colors.white
                          : Colors.black38,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}