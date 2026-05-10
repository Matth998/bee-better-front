import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:flutter/material.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  final List<Map<String, dynamic>> alarms = [
    {'nome': '', 'hora': '05 : 30', 'ativo': true},
    {'nome': '', 'hora': '06 : 00', 'ativo': true},
    {'nome': 'Almoço', 'hora': '12 : 00', 'ativo': false},
    {'nome': '', 'hora': '13 : 00', 'ativo': false},
    {'nome': 'Tomar ba...', 'hora': '18 : 00', 'ativo': true},
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // FUNDO DA COLMEIA
          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo_colmeia.png',
              fit: BoxFit.cover,
            ),
          ),

          // CONTEÚDO
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: 20,
              ),
              child: Column(
                children: [
                  // BOTÃO +
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: FloatingActionButton.small(
                        onPressed: _abrirModalNovoAlarme,
                        backgroundColor: Colors.white,
                        elevation: 4,
                        child: const Icon(Icons.add, color: Colors.black, size: 24),
                      ),
                    ),
                  ),

                  // LISTA DE ALARMES
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: alarms.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) =>
                        _buildAlarmItem(alarms[index], screenHeight),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // CARD DE MEL
                  Container(
                    height: screenHeight * 0.20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('assets/images/mel_escorrendo.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.watch_later_outlined,
                        size: screenHeight * 0.08,
                        color: const Color(0xFF63450E),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: CustomBottomNav(
      //   currentIndex: 0,
      //   onTap: (index) {
      //     if (index == 4) Navigator.pushNamed(context, '/home');
      //     if (index == 1) Navigator.pushNamed(context, '/calendar');
      //     if (index == 3) Navigator.pushNamed(context, '/featuresScreen');
      //     // if (index == 5) Navigator.pushNamed(context, '/menu');
      //   },
      // ),
    );
  }

  Widget _buildAlarmItem(Map<String, dynamic> alarm, double screenHeight) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: screenHeight * 0.015,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // NOME DO ALARME
          SizedBox(
            width: 70,
            child: Text(
              alarm['nome'] ?? '',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // HORÁRIO CENTRALIZADO
          Expanded(
            child: Center(
              child: Text(
                alarm['hora'],
                style: TextStyle(
                  fontSize: screenHeight * 0.035,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // TOGGLE
          SizedBox(
            width: 70,
            child: Align(
              alignment: Alignment.centerRight,
              child: Switch(
                value: alarm['ativo'],
                onChanged: (val) {
                  setState(() => alarm['ativo'] = val);
                },
                activeColor: const Color(0xFFF7941D),
                inactiveThumbColor: Colors.black45,
                inactiveTrackColor: Colors.black12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _abrirModalNovoAlarme() {
    int selectedHour = TimeOfDay.now().hour;
    int selectedMinute = TimeOfDay.now().minute;
    String nomeSelecionado = '';

    final FixedExtentScrollController horaController =
    FixedExtentScrollController(initialItem: selectedHour);
    final FixedExtentScrollController minutoController =
    FixedExtentScrollController(initialItem: selectedMinute);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // HANDLE
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Novo Alarme",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SELETOR DE HORA ESTILO iOS
                  SizedBox(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // HORAS
                        SizedBox(
                          width: 80,
                          child: ListWheelScrollView.useDelegate(
                            controller: horaController,
                            itemExtent: 50,
                            perspective: 0.005,
                            diameterRatio: 1.5,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setModalState(() => selectedHour = index);
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 24,
                              builder: (context, index) {
                                final isSelected = index == selectedHour;
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: isSelected ? 36 : 24,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // SEPARADOR
                        const Text(
                          ":",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // MINUTOS
                        SizedBox(
                          width: 80,
                          child: ListWheelScrollView.useDelegate(
                            controller: minutoController,
                            itemExtent: 50,
                            perspective: 0.005,
                            diameterRatio: 1.5,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setModalState(() => selectedMinute = index);
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 60,
                              builder: (context, index) {
                                final isSelected = index == selectedMinute;
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: isSelected ? 36 : 24,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
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

                  const SizedBox(height: 10),

                  // CAMPO NOME
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Nome",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                hintText: "Inserir nome",
                                hintStyle: TextStyle(color: Colors.black38),
                                border: InputBorder.none,
                                contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                              ),
                              onChanged: (val) {
                                setModalState(() => nomeSelecionado = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // CAMPO TOQUE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Text(
                              "Toque",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Row(
                              children: [
                                Text(
                                  "Toque padrão",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                Icon(Icons.chevron_right,
                                    color: Colors.grey.shade500),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // BOTÃO SALVAR
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                    child: ElevatedButton(
                      onPressed: () {
                        final hora =
                            '${selectedHour.toString().padLeft(2, '0')} : ${selectedMinute.toString().padLeft(2, '0')}';
                        setState(() {
                          alarms.add({
                            'nome': nomeSelecionado,
                            'hora': hora,
                            'ativo': true,
                          });
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7941D),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Salvar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

}