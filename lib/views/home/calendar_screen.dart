import 'package:bee_better_flutter/services/user_session.dart';
import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
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
        Uri.parse(
            'http://localhost:8080/tasks/user/${UserSession.id}?date=$dateStr'),
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
        Uri.parse('http://localhost:8080/tasks/${task['id']}/complete'),
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

  void _mostrarRecompensa() {
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
              const Text('🎉', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text('Tarefa concluída!',
                  style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.monetization_on, color: Color(0xFFF7941D)),
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
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.monetization_on, color: Color(0xFFF7941D)),
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

  void _abrirModalNovaTarefa() {
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    TimeOfDay horaInicio = TimeOfDay.now();
    TimeOfDay horaFim = TimeOfDay(
        hour: TimeOfDay.now().hour,
        minute: TimeOfDay.now().minute + 30 >= 60
            ? TimeOfDay.now().minute + 30 - 60
            : TimeOfDay.now().minute + 30);
    bool recorrente = false;
    bool diaInteiro = false;
    bool naoSeRepete = false;
    String repeticaoSelecionada = 'Todas as semanas';
    List<bool> diasSemana = [false, true, true, false, true, true, true];

    final List<String> nomeDias = [
      'Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'
    ];
    final List<String> opcoesRepeticao = [
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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
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
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF176),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: tituloController,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'Adicionar um nome',
                                  hintStyle:
                                  TextStyle(color: Colors.black45),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                Border.all(color: Colors.grey.shade200),
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
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                            children:
                                            List.generate(7, (i) {
                                              return GestureDetector(
                                                onTap: () => setModalState(
                                                        () => diasSemana[i] =
                                                    !diasSemana[i]),
                                                child: Container(
                                                  width: 28,
                                                  height: 28,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
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
                                                        fontSize: 8,
                                                        fontWeight:
                                                        FontWeight.bold,
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
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black45),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
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
                                              fontWeight: FontWeight.bold)),
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
                            const Text('Descrição:',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF176),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: descricaoController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  hintText: '...',
                                  hintStyle:
                                  TextStyle(color: Colors.black38),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                Border.all(color: Colors.grey.shade200),
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
                                        const Text('Não se repete',
                                            style:
                                            TextStyle(fontSize: 14)),
                                        const Spacer(),
                                        Switch(
                                          value: naoSeRepete,
                                          onChanged: (val) =>
                                              setModalState(
                                                      () => naoSeRepete = val),
                                          activeColor:
                                          const Color(0xFFF7941D),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (naoSeRepete)
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
                                        opcoesRepeticao.map((opcao) {
                                          final selecionada =
                                              repeticaoSelecionada == opcao;
                                          return GestureDetector(
                                            onTap: () => setModalState(() =>
                                            repeticaoSelecionada =
                                                opcao),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 8),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color:
                                                          Colors.black45,
                                                          width: 2),
                                                      color: selecionada
                                                          ? Colors.black87
                                                          : Colors
                                                          .transparent,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(opcao,
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (tituloController.text.isEmpty) return;
                          Navigator.pop(context);
                          await _criarTarefa(tituloController.text,
                              descricaoController.text);
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
            );
          },
        );
      },
    );
  }

  Future<void> _criarTarefa(String titulo, String descricao) async {
    final date = _selectedDay ?? DateTime.now();
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      final body = jsonEncode({
        'title': titulo,
        'description': descricao,
        'user_id': UserSession.id,
        'due_date': dateStr,
      });

      final response = await http.post(
        Uri.parse('http://localhost:8080/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${UserSession.token}',
        },
        body: body,
      );

      if (response.statusCode == 201) {
        await _fetchTasks();
      }
    } catch (e) {
      print('Erro ao criar tarefa: $e');
    }
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
            child: LayoutBuilder( // ← substitui SingleChildScrollView direto
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight, // ← garante altura mínima
                    ),
                    child: Column(
                      children: [
                        _buildDynamicCalendar(),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FloatingActionButton.small(
                            onPressed: _abrirModalNovaTarefa,
                            backgroundColor: Colors.white,
                            elevation: 4,
                            child: const Icon(Icons.add, color: Colors.black),
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
                                color: Colors.black54, fontSize: 16),
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
                              _buildTaskTile(index, screenHeight),
                        ),
                        const SizedBox(height: 20), // ← reduzido de 100 para 20
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
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
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
            decoration: BoxDecoration(color: Color(0xFF3D2B1F)),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            leftChevronIcon:
            Icon(Icons.chevron_left, color: Color(0xFFF7941D), size: 20),
            rightChevronIcon:
            Icon(Icons.chevron_right, color: Color(0xFFF7941D), size: 20),
          ),
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
                color: Color(0xFFF7941D), shape: BoxShape.circle),
            todayDecoration: BoxDecoration(
                color: Color(0xFFFFD100), shape: BoxShape.circle),
            todayTextStyle: TextStyle(
                color: Color(0xFF3D2B1F), fontWeight: FontWeight.bold),
            defaultTextStyle:
            TextStyle(color: Color(0xFF3D2B1F), fontSize: 13),
            weekendTextStyle:
            TextStyle(color: Color(0xFF3D2B1F), fontSize: 13),
            outsideTextStyle: TextStyle(color: Colors.grey, fontSize: 13),
            cellMargin: EdgeInsets.all(2),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskTile(int index, double screenHeight) {
    final task = tasks[index];
    final concluida = task['concluida'] as bool;

    return GestureDetector(
      onTap: () => _completarTarefa(index),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 15, vertical: screenHeight * 0.018),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 5),
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
                  color: const Color(0xFFA2D033),
                  width: 2,
                ),
              ),
              child: concluida
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
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
          ],
        ),
      ),
    );
  }
}