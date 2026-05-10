import 'package:bee_better_flutter/services/user_session.dart';
import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> history = [];
  bool loading = true;

  // Meses exibidos (últimos 4)
  late List<DateTime> months;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    months = List.generate(4, (i) =>
        DateTime(now.year, now.month - 3 + i, 1));
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => loading = true);
    try {
      final start = months.first;
      final end = DateTime(months.last.year, months.last.month + 1, 0);

      final startStr = '${start.year}-${start.month.toString().padLeft(2, '0')}-01';
      final endStr = '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';

      final response = await http.get(
        Uri.parse('http://localhost:8080/daily-progress/history/${UserSession.id}?start=$startStr&end=$endStr'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          history = data.map((d) => {
            'date': d['date'],
            'completed_tasks': d['completed_tasks'] ?? 0,
            'total_tasks': d['total_tasks'] ?? 0,
          }).toList();
        });
      }
    } catch (e) {
      print('Erro ao buscar histórico: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Color _getColor(int completed, int total) {
    if (total == 0 && completed == 0) return Colors.grey.shade200; // sem dados
    if (completed == 0) return const Color(0xFFE57373); // vermelho
    if (completed >= total) return const Color(0xFF81C784); // verde
    return const Color(0xFFFFD54F); // amarelo
  }

  Map<String, dynamic>? _getProgressForDate(String dateStr) {
    try {
      return history.firstWhere((h) => h['date'] == dateStr);
    } catch (_) {
      return null;
    }
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
                            color: const Color(0xFFF7941D), // ← laranja
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.chevron_left, color: Colors.white), // ← ícone branco
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // CARD GRID DE PROGRESSO
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 8)
                            ],
                          ),
                          child: loading
                              ? const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFFF7941D)))
                              : Column(
                            children: [
                              // CABEÇALHO DOS MESES
                              Row(
                                children: [
                                  const SizedBox(width: 30),
                                  ...months.map((m) => Expanded(
                                    child: Center(
                                      child: Text(
                                        _monthName(m.month),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  )),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // GRID POR DIA DA SEMANA
                              ...List.generate(7, (dayIndex) {
                                final diasSemana = [
                                  'Dom', 'Seg', 'Ter', 'Qua',
                                  'Qui', 'Sex', 'Sáb'
                                ];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        child: Text(
                                          diasSemana[dayIndex],
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black45,
                                          ),
                                        ),
                                      ),
                                      ...months.map((month) {
                                        return Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceEvenly,
                                            children: _getDaysOfWeekInMonth(
                                                month, dayIndex)
                                                .map((date) {
                                              final dateStr =
                                                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                                              final progress =
                                              _getProgressForDate(
                                                  dateStr);
                                              final completed = progress?[
                                              'completed_tasks'] ??
                                                  0;
                                              final total =
                                                  progress?['total_tasks'] ??
                                                      0;
                                              final isFuture = date
                                                  .isAfter(DateTime.now());

                                              return Container(
                                                width: 8,
                                                height: 8,
                                                margin: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 1),
                                                decoration: BoxDecoration(
                                                  color: isFuture
                                                      ? Colors
                                                      .grey.shade100
                                                      : _getColor(
                                                      completed,
                                                      total),
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(2),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              }),

                              const SizedBox(height: 12),

                              // LEGENDA
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  _buildLegend(
                                      const Color(0xFF81C784),
                                      'Positivo'),
                                  const SizedBox(width: 16),
                                  _buildLegend(
                                      const Color(0xFFFFD54F),
                                      'Neutro'),
                                  const SizedBox(width: 16),
                                  _buildLegend(
                                      const Color(0xFFE57373),
                                      'Negativo'),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // CARD METAS (placeholder)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(0xFF64B5F6), width: 1.5),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 8)
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('Metas',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text('Essa semana v',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black45)),
                                ],
                              ),
                              const Text('0 Metas concluídas',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black45)),
                              const SizedBox(height: 20),
                              const Center(
                                child: Text(
                                  'Nenhuma meta concluída nesse período.\nAdicione e conclua metas para ter acesso ao insight.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black45, fontSize: 13),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
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
        currentIndex: 3,
        onTap: (index) {
          if (index == 4) Navigator.pushNamed(context, '/home');
          if (index == 0) Navigator.pushNamed(context, '/alarms');
          if (index == 1) Navigator.pushNamed(context, '/calendar');
        },
      ),
    );
  }

  // Retorna todos os dias de um mês que caem num dia da semana específico
  List<DateTime> _getDaysOfWeekInMonth(DateTime month, int weekday) {
    final List<DateTime> days = [];
    final daysInMonth =
        DateTime(month.year, month.month + 1, 0).day;

    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      if (date.weekday % 7 == weekday) {
        // weekday: Dom=0, Seg=1... Sáb=6
        days.add(date);
      }
    }
    return days;
  }

  String _monthName(int month) {
    const names = [
      '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return names[month];
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }
}