import 'package:bee_better_flutter/constants.dart';
import 'package:bee_better_flutter/services/user_session.dart';
import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> tasks = [];
  bool loadingTasks = true;
  static const String _baseUrl = AppConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() => loadingTasks = true);
    try {
      final date = _selectedDay ?? DateTime.now();
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final response = await http.get(
        Uri.parse('$_baseUrl/tasks/user/${UserSession.id}?date=$dateStr'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          tasks = data
              .map((t) => {
            'id': t['id'],
            'titulo': t['title'],
            'descricao': t['description'] ?? '',
            'concluida': t['completed'],
            'isMission': t['is_mission'] ?? false,
            'targetCount': t['target_count'] ?? 0,
            'currentCount': t['current_count'] ?? 0,
          })
              .toList();
        });
      }
    } catch (e) {
      print('Erro ao buscar tarefas: $e');
    } finally {
      setState(() => loadingTasks = false);
    }
  }

  Future<void> _completarTarefa(int index) async {
    final task = tasks[index];
    if (task['concluida']) return;

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/tasks/${task['id']}/complete'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );

      if (response.statusCode == 200) {
        setState(() => tasks[index]['concluida'] = true);
        UserSession.moedas += 10;
        UserSession.experiencia += 20;
        if (UserSession.experiencia >= UserSession.nivel * 100) {
          UserSession.nivel += 1;
          UserSession.experiencia = 0;
          _mostrarLevelUp();
        } else {
          _mostrarRecompensa();
        }
      }
    } catch (e) {
      print('Erro ao completar tarefa: $e');
    }
  }

  Future<void> _incrementarMissao(int index) async {
    final task = tasks[index];
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/tasks/${task['id']}/progress?increment=1'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          tasks[index]['currentCount'] = data['current_count'];
          tasks[index]['targetCount'] = data['target_count'];
          tasks[index]['concluida'] = data['completed'];
        });
        if (data['completed'] == true) _mostrarRecompensa();
      }
    } catch (e) {
      print('Erro ao incrementar missão: $e');
    }
  }

  Future<void> _mostrarRecompensa() async {
    final prefs = await SharedPreferences.getInstance();
    final String tipoComemoracao =
        prefs.getString('tipo_comemoracao') ?? 'animado';
    final String imagePath = tipoComemoracao == 'estatico'
        ? 'assets/images/comemoracao_estatico.png'
        : 'assets/images/comemoracao_animado.png';

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDE7),
            borderRadius: BorderRadius.circular(16),
            border:
            Border.all(color: const Color(0xFFE0DB9A), width: 1),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 5))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 45,
                    height: 45,
                    child: Image.asset(imagePath, fit: BoxFit.contain),
                  ),
                  const Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Parabéns!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Você concluiu a tarefa!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 45,
                    height: 45,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(3.14159),
                      child:
                      Image.asset(imagePath, fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monetization_on,
                      color: Color(0xFFF7941D), size: 22),
                  SizedBox(width: 4),
                  Text('+10 moedas',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold)),
                  SizedBox(width: 24),
                  Icon(Icons.star,
                      color: Color(0xFF26A69A), size: 22),
                  SizedBox(width: 4),
                  Text('+20 XP',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    });
  }

  void _mostrarLevelUp() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 20)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🐝', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'Level Up! Nível ${UserSession.nivel}',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF7941D)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Uma nova abelha apareceu na sua colmeia!',
                textAlign: TextAlign.center,
                style:
                TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.monetization_on,
                      color: Color(0xFFF7941D)),
                  SizedBox(width: 4),
                  Text('+10 moedas',
                      style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFF7941D),
                          fontWeight: FontWeight.bold)),
                  SizedBox(width: 16),
                  Icon(Icons.star, color: Color(0xFFFFD100)),
                  SizedBox(width: 4),
                  Text('+20 XP',
                      style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFFFD100),
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    });
  }

  // ── Mapeia opção de repetição para enum do backend ────────────────────────
  String _mapRepeticao(String repeticao) => switch (repeticao) {
    'Todos os dias' => 'DAILY',
    'Todas as semanas' => 'WEEKLY',
    'Todos os meses' => 'MONTHLY',
    'Todos os anos' => 'YEARLY',
    _ => 'DAILY',
  };

  // ─── MODAL ESCOLHA ────────────────────────────────────────────────────────
  void _abrirModalEscolha() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Escolha',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text(
              'Selecione se deseja adicionar uma meta ou uma missão',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _abrirModalMeta();
                    },
                    style: OutlinedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text('Meta',
                        style: TextStyle(
                            fontSize: 16, color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _abrirModalMissao();
                    },
                    style: OutlinedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text('Missão',
                        style: TextStyle(
                            fontSize: 16, color: Colors.black87)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── MODAL META ───────────────────────────────────────────────────────────
  void _abrirModalMeta() {
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    final divideController = TextEditingController();
    bool recorrente = false;
    bool diaInteiro = true;
    bool seRepete = false;
    bool divide = false;
    String repeticao = 'Todos os dias';
    List<bool> diasSemana = [false, true, true, false, true, true, true];
    TimeOfDay horaInicio = TimeOfDay.now();
    TimeOfDay horaFim = TimeOfDay.now();

    final nomeDias = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final opcoesRepeticao = [
      'Todos os dias',
      'Todas as semanas',
      'Todos os meses',
      'Todos os anos',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NOME
                        _buildTextField(
                            tituloController, 'Adicionar um nome'),
                        const SizedBox(height: 12),

                        // RECORRENTE
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text('Recorrente',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  Switch(
                                    value: recorrente,
                                    onChanged: (val) => setModalState(
                                            () => recorrente = val),
                                    activeColor:
                                    const Color(0xFFF7941D),
                                  ),
                                  if (recorrente)
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection:
                                        Axis.horizontal,
                                        child: Row(
                                          children:
                                          List.generate(7, (i) {
                                            return GestureDetector(
                                              onTap: () =>
                                                  setModalState(() =>
                                                  diasSemana[i] =
                                                  !diasSemana[
                                                  i]),
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                margin: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 2),
                                                decoration:
                                                BoxDecoration(
                                                  shape:
                                                  BoxShape.circle,
                                                  color: diasSemana[i]
                                                      ? const Color(
                                                      0xFFF7941D)
                                                      : const Color(
                                                      0xFFFFF9C4),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    nomeDias[i],
                                                    style: TextStyle(
                                                      fontSize: 7,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color: diasSemana[
                                                      i]
                                                          ? Colors
                                                          .white
                                                          : Colors
                                                          .black54,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (recorrente)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    'Ativando a recorrência ela ficará ativa semanalmente',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.black45),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // DIA INTEIRO
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 18, color: Colors.black54),
                              const SizedBox(width: 8),
                              const Text('Dia inteiro',
                                  style: TextStyle(fontSize: 14)),
                              Switch(
                                value: diaInteiro,
                                onChanged: (val) => setModalState(
                                        () => diaInteiro = val),
                                activeColor: const Color(0xFFF7941D),
                              ),
                              const Spacer(),
                              if (!diaInteiro) ...[
                                GestureDetector(
                                  onTap: () async {
                                    final picked = await showTimePicker(
                                        context: context,
                                        initialTime: horaInicio);
                                    if (picked != null)
                                      setModalState(
                                              () => horaInicio = picked);
                                  },
                                  child: Text(
                                    '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: Text(' - ',
                                      style: TextStyle(
                                          fontWeight:
                                          FontWeight.bold)),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final picked = await showTimePicker(
                                        context: context,
                                        initialTime: horaFim);
                                    if (picked != null)
                                      setModalState(
                                              () => horaFim = picked);
                                  },
                                  child: Text(
                                    '${horaFim.hour.toString().padLeft(2, '0')}:${horaFim.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // DESCRIÇÃO
                        const Text('Descrição:',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        const SizedBox(height: 8),
                        _buildTextField(descricaoController, '...',
                            maxLines: 3),
                        const SizedBox(height: 12),

                        // DIVIDE
                        _buildDivideRow(
                            divide,
                            divideController,
                                (val) =>
                                setModalState(() => divide = val)),
                        const SizedBox(height: 12),

                        // SE REPETE
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.repeat,
                                        size: 18,
                                        color: Colors.black54),
                                    const SizedBox(width: 8),
                                    const Text('Se repete',
                                        style: TextStyle(
                                            fontSize: 14)),
                                    const Spacer(),
                                    Switch(
                                      value: seRepete,
                                      onChanged: (val) =>
                                          setModalState(
                                                  () => seRepete = val),
                                      activeColor:
                                      const Color(0xFFF7941D),
                                    ),
                                  ],
                                ),
                              ),
                              if (seRepete)
                                Container(
                                  margin: const EdgeInsets.fromLTRB(
                                      12, 0, 12, 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF176),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children:
                                    opcoesRepeticao.map((op) {
                                      final sel = repeticao == op;
                                      return GestureDetector(
                                        onTap: () => setModalState(
                                                () => repeticao = op),
                                        child: Padding(
                                          padding: const EdgeInsets
                                              .symmetric(vertical: 8),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 20,
                                                height: 20,
                                                decoration:
                                                BoxDecoration(
                                                  shape:
                                                  BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors
                                                          .black45,
                                                      width: 2),
                                                  color: sel
                                                      ? Colors.black87
                                                      : Colors
                                                      .transparent,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(op,
                                                  style: const TextStyle(
                                                      fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // BOTÃO SALVAR
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (tituloController.text.isEmpty) return;
                      Navigator.pop(context);
                      await _criarItem(
                        titulo: tituloController.text,
                        descricao: descricaoController.text,
                        isMission: false,
                        targetCount: divide &&
                            divideController.text.isNotEmpty
                            ? int.tryParse(divideController.text)
                            : null,
                        recurrence: seRepete
                            ? _mapRepeticao(repeticao)
                            : null,
                        recurrenceEndDate: seRepete
                            ? DateTime.now()
                            .add(const Duration(days: 365))
                            : null,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7941D),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Salvar',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── MODAL MISSÃO ─────────────────────────────────────────────────────────
  void _abrirModalMissao() {
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    final divideController = TextEditingController();
    bool divide = false;
    DateTime periodoInicio = _selectedDay ?? DateTime.now();
    DateTime periodoFim =
    (_selectedDay ?? DateTime.now()).add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                            tituloController, 'Adicionar um nome'),
                        const SizedBox(height: 12),

                        // PERÍODO
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month,
                                  size: 18, color: Colors.black54),
                              const SizedBox(width: 8),
                              const Text('Período',
                                  style: TextStyle(fontSize: 14)),
                              const Spacer(),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: periodoInicio,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null)
                                    setModalState(
                                            () => periodoInicio = picked);
                                },
                                child: Text(
                                  '${periodoInicio.day.toString().padLeft(2, '0')}/${periodoInicio.month.toString().padLeft(2, '0')}/${periodoInicio.year}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4),
                                child: Text(' - ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: periodoFim,
                                    firstDate: periodoInicio,
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null)
                                    setModalState(
                                            () => periodoFim = picked);
                                },
                                child: Text(
                                  '${periodoFim.day.toString().padLeft(2, '0')}/${periodoFim.month.toString().padLeft(2, '0')}/${periodoFim.year}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        const Text('Descrição:',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        const SizedBox(height: 8),
                        _buildTextField(descricaoController, '...',
                            maxLines: 3),
                        const SizedBox(height: 12),

                        _buildDivideRow(
                            divide,
                            divideController,
                                (val) =>
                                setModalState(() => divide = val)),
                      ],
                    ),
                  ),
                ),

                // BOTÃO SALVAR
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (tituloController.text.isEmpty) return;
                      Navigator.pop(context);
                      await _criarItem(
                        titulo: tituloController.text,
                        descricao: descricaoController.text,
                        isMission: true,
                        targetCount: divide &&
                            divideController.text.isNotEmpty
                            ? int.tryParse(divideController.text)
                            : 1,
                        dueDate: periodoInicio,
                        recurrenceEndDate: periodoFim,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7941D),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Salvar',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _criarItem({
    required String titulo,
    required String descricao,
    required bool isMission,
    int? targetCount,
    DateTime? dueDate,
    DateTime? recurrenceEndDate,
    String? recurrence,
  }) async {
    final date = dueDate ?? _selectedDay ?? DateTime.now();
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    String? endDateStr;
    if (recurrenceEndDate != null) {
      endDateStr =
      '${recurrenceEndDate.year}-${recurrenceEndDate.month.toString().padLeft(2, '0')}-${recurrenceEndDate.day.toString().padLeft(2, '0')}';
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${UserSession.token}',
        },
        body: jsonEncode({
          'title': titulo,
          'description': descricao,
          'user_id': UserSession.id,
          'due_date': dateStr,
          'is_mission': isMission,
          'target_count': targetCount ?? 1,
          if (recurrence != null) 'recurrence': recurrence,
          if (endDateStr != null) 'recurrence_end_date': endDateStr,
        }),
      );
      if (response.statusCode == 201) {
        await _fetchTasks();
      }
    } catch (e) {
      print('Erro ao criar: $e');
    }
  }

  // ─── WIDGETS AUXILIARES ───────────────────────────────────────────────────
  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF176),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textAlign:
        maxLines == 1 ? TextAlign.center : TextAlign.start,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black45),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDivideRow(bool divide, TextEditingController controller,
      Function(bool) onChanged) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Text('Divide',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          Switch(
            value: divide,
            onChanged: onChanged,
            activeColor: const Color(0xFFF7941D),
          ),
          if (divide)
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  hintText: 'Quantas vezes?',
                  hintStyle: TextStyle(color: Colors.black38),
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        _buildDynamicCalendar(),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FloatingActionButton.small(
                            onPressed: _abrirModalEscolha,
                            backgroundColor: Colors.white,
                            elevation: 4,
                            child: const Icon(Icons.add,
                                color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 10),
                        loadingTasks
                            ? const CircularProgressIndicator(
                            color: Color(0xFFF7941D))
                            : tasks.isEmpty
                            ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Nenhuma tarefa ainda.\nClique em + para adicionar!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16),
                          ),
                        )
                            : ListView.separated(
                          shrinkWrap: true,
                          physics:
                          const NeverScrollableScrollPhysics(),
                          itemCount: tasks.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                          itemBuilder: (_, index) =>
                              _buildTaskTile(
                                  index, screenHeight),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 4) Navigator.pushNamed(context, '/home');
          if (index == 0) Navigator.pushNamed(context, '/alarms');
          if (index == 3) Navigator.pushNamed(context, '/featuresScreen');
          if (index == 5) Navigator.pushNamed(context, '/menu');
        },
      ),
    );
  }

  Widget _buildDynamicCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: TableCalendar(
          locale: 'pt_BR',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _fetchTasks();
          },
          rowHeight: 36,
          daysOfWeekHeight: 24,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            headerPadding: EdgeInsets.symmetric(vertical: 6),
            decoration:
            BoxDecoration(color: Color(0xFF3D2B1F)),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            leftChevronIcon: Icon(Icons.chevron_left,
                color: Color(0xFFF7941D), size: 20),
            rightChevronIcon: Icon(Icons.chevron_right,
                color: Color(0xFFF7941D), size: 20),
          ),
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
                color: Color(0xFFF7941D), shape: BoxShape.circle),
            todayDecoration: BoxDecoration(
                color: Color(0xFFFFD100), shape: BoxShape.circle),
            todayTextStyle: TextStyle(
                color: Color(0xFF3D2B1F),
                fontWeight: FontWeight.bold),
            defaultTextStyle:
            TextStyle(color: Color(0xFF3D2B1F), fontSize: 13),
            weekendTextStyle:
            TextStyle(color: Color(0xFF3D2B1F), fontSize: 13),
            outsideTextStyle:
            TextStyle(color: Colors.grey, fontSize: 13),
            cellMargin: EdgeInsets.all(2),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskTile(int index, double screenHeight) {
    final task = tasks[index];
    final concluida = task['concluida'] as bool;
    final isMission = task['isMission'] as bool;
    final current = task['currentCount'] as int;
    final target = task['targetCount'] as int;
    final temProgresso = target > 1;

    return GestureDetector(
      onTap: () {
        if (isMission || temProgresso) {
          _incrementarMissao(index);
        } else {
          _completarTarefa(index);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 15, vertical: screenHeight * 0.018),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: concluida
                    ? const Color(0xFFA2D033)
                    : Colors.transparent,
                border: Border.all(
                  color: concluida
                      ? const Color(0xFFA2D033)
                      : const Color(0xFFF7941D),
                  width: 2,
                ),
              ),
              child: concluida
                  ? const Icon(Icons.check,
                  size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                task['titulo'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  decoration: concluida
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: concluida ? Colors.grey : Colors.black,
                ),
              ),
            ),
            if (temProgresso)
              Text(
                '$current/$target',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: concluida
                      ? Colors.grey
                      : const Color(0xFFF7941D),
                ),
              ),
          ],
        ),
      ),
    );
  }
}