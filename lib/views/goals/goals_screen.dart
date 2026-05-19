import 'package:bee_better_flutter/services/user_session.dart';
import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// TIPOS DE TELA
enum GoalScreenType { today, inProgress, completed, missions }

class GoalsScreen extends StatefulWidget {
  final GoalScreenType type;

  const GoalsScreen({super.key, required this.type});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<Map<String, dynamic>> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  String get _title => switch (widget.type) {
    GoalScreenType.today => 'Metas para hoje',
    GoalScreenType.inProgress => 'Metas em andamento',
    GoalScreenType.completed => 'Tarefas concluídas',
    GoalScreenType.missions => 'Missões',
  };

  String get _endpoint => switch (widget.type) {
    GoalScreenType.today =>
    'http://localhost:8080/tasks/user/${UserSession.id}/today',
    GoalScreenType.inProgress =>
    'http://localhost:8080/tasks/user/${UserSession.id}/in-progress',
    GoalScreenType.completed =>
    'http://localhost:8080/tasks/user/${UserSession.id}/completed',
    GoalScreenType.missions =>
    'http://localhost:8080/tasks/user/${UserSession.id}/missions',
  };

  Future<void> _fetch() async {
    setState(() => loading = true);
    try {
      final response = await http.get(
        Uri.parse(_endpoint),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          items = data
              .map((t) => {
            'id': t['id'],
            'titulo': t['title'] ?? '',
            'concluida': t['completed'] ?? false,
            'isMission': t['is_mission'] ?? false,
            'targetCount': t['target_count'] ?? 0,
            'currentCount': t['current_count'] ?? 0,
            'progressRate': t['progress_rate'],
          })
              .toList();
        });
      }
    } catch (e) {
      print('Erro: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _completarItem(int index) async {
    final item = items[index];
    if (item['concluida']) return;

    try {
      final response = await http.patch(
        Uri.parse('http://localhost:8080/tasks/${item['id']}/complete'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );
      if (response.statusCode == 200) {
        setState(() => items[index]['concluida'] = true);
        UserSession.moedas += 10;
        UserSession.experiencia += 20;
        _mostrarRecompensa();
      }
    } catch (e) {
      print('Erro ao completar: $e');
    }
  }

  Future<void> _incrementarMissao(int index) async {
    final item = items[index];
    try {
      final response = await http.patch(
        Uri.parse(
            'http://localhost:8080/tasks/${item['id']}/progress?increment=1'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          items[index]['currentCount'] = data['current_count'];
          items[index]['targetCount'] = data['target_count'];
          items[index]['concluida'] = data['completed'];
        });
        if (data['completed'] == true) _mostrarRecompensa();
      }
    } catch (e) {
      print('Erro ao incrementar missão: $e');
    }
  }

  void _mostrarRecompensa() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text('Concluído!',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.monetization_on, color: Color(0xFFF7941D)),
                  SizedBox(width: 4),
                  Text('+10 moedas',
                      style: TextStyle(
                          color: Color(0xFFF7941D),
                          fontWeight: FontWeight.bold)),
                  SizedBox(width: 16),
                  Icon(Icons.star, color: Color(0xFFFFD100)),
                  SizedBox(width: 4),
                  Text('+20 XP',
                      style: TextStyle(
                          color: Color(0xFFFFD100),
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
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
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

  void _abrirModalMeta() {
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    final divideController = TextEditingController();
    bool recorrente = false;
    bool diaInteiro = true;
    bool naoSeRepete = false;
    String repeticao = 'Todas as semanas';
    List<bool> diasSemana = [false, true, true, false, true, true, true];
    TimeOfDay horaInicio = TimeOfDay.now();
    TimeOfDay horaFim = TimeOfDay.now();
    bool divide = false;

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
                        _buildTextField(tituloController, 'Adicionar um nome'),
                        const SizedBox(height: 12),

                        // RECORRENTE
                        _buildRecorrenteRow(
                          recorrente, diasSemana, nomeDias,
                              (val) => setModalState(() => recorrente = val),
                              (i) => setModalState(
                                  () => diasSemana[i] = !diasSemana[i]),
                        ),
                        const SizedBox(height: 12),

                        // DIA INTEIRO / HORÁRIO
                        _buildDiaInteiroRow(
                          diaInteiro, horaInicio, horaFim,
                              (val) => setModalState(() => diaInteiro = val),
                              (h) => setModalState(() => horaInicio = h),
                              (h) => setModalState(() => horaFim = h),
                          context,
                        ),
                        const SizedBox(height: 12),

                        // DESCRIÇÃO
                        const Text('Descrição:',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 8),
                        _buildTextField(descricaoController, '...',
                            maxLines: 3),
                        const SizedBox(height: 12),

                        // DIVIDE
                        _buildDivideRow(
                          divide, divideController,
                              (val) => setModalState(() => divide = val),
                        ),
                        const SizedBox(height: 12),

                        // NÃO SE REPETE
                        _buildRepeticaoRow(
                          naoSeRepete, repeticao, opcoesRepeticao,
                              (val) => setModalState(() => naoSeRepete = val),
                              (op) =>
                              setModalState(() => repeticao = op),
                        ),
                      ],
                    ),
                  ),
                ),

                // BOTÃO SALVAR
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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

  void _abrirModalMissao() {
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    final divideController = TextEditingController();
    bool divide = false;
    DateTime periodoInicio = DateTime.now();
    DateTime periodoFim = DateTime.now().add(const Duration(days: 30));

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
                        // NOME
                        _buildTextField(tituloController, 'Adicionar um nome'),
                        const SizedBox(height: 12),

                        // PERÍODO
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border:
                            Border.all(color: Colors.grey.shade200),
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
                                padding:
                                EdgeInsets.symmetric(horizontal: 4),
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

                        // DESCRIÇÃO
                        const Text('Descrição:',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 8),
                        _buildTextField(descricaoController, '...',
                            maxLines: 3),
                        const SizedBox(height: 12),

                        // DIVIDE
                        _buildDivideRow(
                          divide, divideController,
                              (val) => setModalState(() => divide = val),
                        ),
                      ],
                    ),
                  ),
                ),

                // BOTÃO SALVAR
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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
  }) async {
    final date = dueDate ?? DateTime.now();
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    String? endDateStr;
    if (recurrenceEndDate != null) {
      endDateStr =
      '${recurrenceEndDate.year}-${recurrenceEndDate.month.toString().padLeft(2, '0')}-${recurrenceEndDate.day.toString().padLeft(2, '0')}';
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/tasks'),
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
          if (endDateStr != null) 'recurrence_end_date': endDateStr,
        }),
      );
      if (response.statusCode == 201) {
        await _fetch();
      }
    } catch (e) {
      print('Erro ao criar: $e');
    }
  }

  // ─── WIDGETS AUXILIARES ───────────────────────────────────────────

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
              style:
              TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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

  Widget _buildRecorrenteRow(
      bool recorrente,
      List<bool> diasSemana,
      List<String> nomeDias,
      Function(bool) onRecorrenteChanged,
      Function(int) onDiaChanged,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Recorrente',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              Switch(
                value: recorrente,
                onChanged: onRecorrenteChanged,
                activeColor: const Color(0xFFF7941D),
              ),
              if (recorrente)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (i) {
                      return GestureDetector(
                        onTap: () => onDiaChanged(i),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: diasSemana[i]
                                ? const Color(0xFFF7941D)
                                : const Color(0xFFFFF9C4),
                          ),
                          child: Center(
                            child: Text(
                              nomeDias[i],
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: diasSemana[i]
                                    ? Colors.white
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
          if (recorrente)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                'Ativando a recorrência ela ficará ativa semanalmente',
                style: TextStyle(fontSize: 10, color: Colors.black45),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDiaInteiroRow(
      bool diaInteiro,
      TimeOfDay horaInicio,
      TimeOfDay horaFim,
      Function(bool) onChanged,
      Function(TimeOfDay) onInicioChanged,
      Function(TimeOfDay) onFimChanged,
      BuildContext context,
      ) {
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
          const Icon(Icons.access_time,
              size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          const Text('Dia inteiro',
              style: TextStyle(fontSize: 14)),
          Switch(
            value: diaInteiro,
            onChanged: onChanged,
            activeColor: const Color(0xFFF7941D),
          ),
          const Spacer(),
          if (!diaInteiro) ...[
            GestureDetector(
              onTap: () async {
                final picked = await showTimePicker(
                    context: context, initialTime: horaInicio);
                if (picked != null) onInicioChanged(picked);
              },
              child: Text(
                '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(' - ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            GestureDetector(
              onTap: () async {
                final picked = await showTimePicker(
                    context: context, initialTime: horaFim);
                if (picked != null) onFimChanged(picked);
              },
              child: Text(
                '${horaFim.hour.toString().padLeft(2, '0')}:${horaFim.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRepeticaoRow(
      bool naoSeRepete,
      String repeticao,
      List<String> opcoes,
      Function(bool) onChanged,
      Function(String) onOpcaoChanged,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.repeat,
                    size: 18, color: Colors.black54),
                const SizedBox(width: 8),
                const Text('Não se repete',
                    style: TextStyle(fontSize: 14)),
                const Spacer(),
                Switch(
                  value: naoSeRepete,
                  onChanged: onChanged,
                  activeColor: const Color(0xFFF7941D),
                ),
              ],
            ),
          ),
          if (naoSeRepete)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF176),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: opcoes.map((op) {
                  final sel = repeticao == op;
                  return GestureDetector(
                    onTap: () => onOpcaoChanged(op),
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.black45, width: 2),
                              color: sel
                                  ? Colors.black87
                                  : Colors.transparent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(op,
                              style:
                              const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fundo_colmeia.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
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
                    const SizedBox(width: 12),
                    Text(
                      _title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // BOTÃO +
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 8),
                  child: FloatingActionButton.small(
                    onPressed: _abrirModalEscolha,
                    backgroundColor: Colors.white,
                    elevation: 2,
                    child:
                    const Icon(Icons.add, color: Colors.black),
                  ),
                ),
              ),

              // LISTA
              Expanded(
                child: loading
                    ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFF7941D)))
                    : items.isEmpty
                    ? Center(
                  child: Text(
                    'Nenhum item ainda.\nClique em + para adicionar!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16),
                  ),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
                  itemBuilder: (_, index) =>
                      _buildItem(index),
                ),
              ),
            ],
          ),
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

  Widget _buildItem(int index) {
    final item = items[index];
    final concluida = item['concluida'] as bool;
    final isMission = item['isMission'] as bool;
    final current = item['currentCount'] as int;
    final target = item['targetCount'] as int;
    final temProgresso = target > 1;

    return GestureDetector(
      onTap: () {
        if (isMission) {
          _incrementarMissao(index);
        } else {
          _completarItem(index);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            // BOLINHA
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
            const SizedBox(width: 12),

            // TÍTULO
            Expanded(
              child: Text(
                item['titulo'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration: concluida
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: concluida ? Colors.grey : Colors.black,
                ),
              ),
            ),

            // PROGRESSO (se tiver)
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