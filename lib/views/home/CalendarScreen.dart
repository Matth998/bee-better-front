import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<String> tasks = [
    "Comprar o bolo",
    "Limpar a casa",
    "Tirar o lixo",
    "Lavar o cabelo",
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // FUNDO COLMEIA
          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo_colmeia.png',
              fit: BoxFit.cover,
            ),
          ),

          // CONTEÚDO
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // CALENDÁRIO DINÂMICO
                  _buildDynamicCalendar(),

                  const SizedBox(height: 20),

                  // BOTÃO ADICIONAR (+)
                  Align(
                    alignment: Alignment.centerRight,
                    child: FloatingActionButton.small(
                      onPressed: () {},
                      backgroundColor: Colors.white,
                      elevation: 4,
                      child: const Icon(Icons.add, color: Colors.black),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // LISTA DE TAREFAS
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) => _buildTaskTile(tasks[index], screenHeight),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
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
          },
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            decoration: BoxDecoration(
              color: Color(0xFF3D2B1F),
            ),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFFF7941D)),
            rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFFF7941D)),
          ),
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Color(0xFFF7941D),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Color(0xFFFFD100),
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: Color(0xFF3D2B1F),
              fontWeight: FontWeight.bold,
            ),
            defaultTextStyle: TextStyle(color: Color(0xFF3D2B1F)),
            weekendTextStyle: TextStyle(color: Color(0xFF3D2B1F)),
            outsideTextStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskTile(String title, double screenHeight) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: screenHeight * 0.018),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFA2D033), width: 2),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}