import 'package:bee_better_flutter/services/user_session.dart';
import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  List<Map<String, dynamic>> alarms = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlarms();
  }

  Future<void> _fetchAlarms() async {
    setState(() => loading = true);
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/alarms/user/${UserSession.id}'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          alarms = data
              .map((a) => {
            'id': a['id'],
            'nome': a['label'] ?? '',
            'hora': _formatTime(a['time']),
            'ativo': a['active'],
            'toque': a['ringtone'] ?? 'toque_1',
          })
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar alarmes: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  String _formatTime(String? time) {
    if (time == null) return '00 : 00';
    final parts = time.split(':');
    return '${parts[0].padLeft(2, '0')} : ${parts[1].padLeft(2, '0')}';
  }

  Future<void> _criarAlarme(
      int hora,
      int minuto,
      String nome,
      String toque,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/alarms/user/${UserSession.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${UserSession.token}',
        },
        body: jsonEncode({
          'time':
          '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}:00',
          'label': nome,
          'ringtone': toque,
        }),
      );
      if (response.statusCode == 201) {
        await _fetchAlarms();
      }
    } catch (e) {
      debugPrint('Erro ao criar alarme: $e');
    }
  }

  Future<void> _toggleAlarme(int index) async {
    final alarm = alarms[index];
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:8080/alarms/${alarm['id']}/toggle'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );
      if (response.statusCode == 200) {
        setState(() => alarms[index]['ativo'] = !alarms[index]['ativo']);
      }
    } catch (e) {
      debugPrint('Erro ao toggle alarme: $e');
    }
  }

  Future<void> _deletarAlarme(int index) async {
    final alarm = alarms[index];
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8080/alarms/${alarm['id']}'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );
      if (response.statusCode == 204) {
        setState(() => alarms.removeAt(index));
      }
    } catch (e) {
      debugPrint('Erro ao deletar alarme: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fundo_colmeia.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: 20,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: FloatingActionButton.small(
                        onPressed: _abrirModalNovoAlarme,
                        backgroundColor: Colors.white,
                        elevation: 4,
                        child: const Icon(
                          Icons.add,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  loading
                      ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFF7941D),
                    ),
                  )
                      : alarms.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Nenhum alarme ainda.\nClique em + para adicionar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  )
                      : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: alarms.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                    itemBuilder: (_, index) =>
                        _buildAlarmItem(index, screenHeight),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Container(
                    height: screenHeight * 0.20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/mel_escorrendo.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/pomodoro'),
                            child: Center(
                              child: Icon(
                                Icons.watch_later_outlined,
                                size: screenHeight * 0.08,
                                color: const Color(0xFF63450E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 4) Navigator.pushNamed(context, '/home');
          if (index == 1) Navigator.pushNamed(context, '/calendar');
          if (index == 3) Navigator.pushNamed(context, '/featuresScreen');
          if (index == 5) Navigator.pushNamed(context, '/menu');
        },
      ),
    );
  }

  Widget _buildAlarmItem(int index, double screenHeight) {
    final alarm = alarms[index];
    return Dismissible(
      key: Key(alarm['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text(
              'Excluir alarme',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text('Deseja excluir este alarme?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
            false;
      },
      onDismissed: (_) => _deletarAlarme(index),
      child: Container(
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
            SizedBox(
              width: 70,
              child: Text(
                alarm['nome'] ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
            SizedBox(
              width: 70,
              child: Align(
                alignment: Alignment.centerRight,
                child: Switch(
                  value: alarm['ativo'],
                  onChanged: (_) => _toggleAlarme(index),
                  activeColor: const Color(0xFFF7941D),
                  inactiveThumbColor: Colors.black45,
                  inactiveTrackColor: Colors.black12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirModalNovoAlarme() {
    int selectedHour = TimeOfDay.now().hour;
    int selectedMinute = TimeOfDay.now().minute;
    String nomeSelecionado = '';
    String toqueSelecionado = 'toque_1';
    String toqueLabel = 'Toque 1';

    final horaController = FixedExtentScrollController(
      initialItem: selectedHour,
    );
    final minutoController = FixedExtentScrollController(
      initialItem: selectedMinute,
    );

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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          child: ListWheelScrollView.useDelegate(
                            controller: horaController,
                            itemExtent: 50,
                            perspective: 0.005,
                            diameterRatio: 1.5,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (i) =>
                                setModalState(() => selectedHour = i),
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 24,
                              builder: (_, i) {
                                final sel = i == selectedHour;
                                return Center(
                                  child: Text(
                                    i.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: sel ? 36 : 24,
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
                        const Text(
                          ":",
                          style: TextStyle(
                              fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 80,
                          child: ListWheelScrollView.useDelegate(
                            controller: minutoController,
                            itemExtent: 50,
                            perspective: 0.005,
                            diameterRatio: 1.5,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (i) =>
                                setModalState(() => selectedMinute = i),
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 60,
                              builder: (_, i) {
                                final sel = i == selectedMinute;
                                return Center(
                                  child: Text(
                                    i.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: sel ? 36 : 24,
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
                  const SizedBox(height: 10),
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
                                  fontSize: 16, color: Colors.black87),
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
                              onChanged: (val) =>
                                  setModalState(() => nomeSelecionado = val),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: GestureDetector(
                      onTap: () async {
                        final result = await _abrirModalToque(
                          context,
                          toqueSelecionado,
                        );
                        if (result != null) {
                          setModalState(() {
                            toqueSelecionado = result['assetName']!;
                            toqueLabel = result['label']!;
                          });
                        }
                      },
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
                                    fontSize: 16, color: Colors.black87),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Row(
                                children: [
                                  Text(
                                    toqueLabel,
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
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _criarAlarme(
                          selectedHour,
                          selectedMinute,
                          nomeSelecionado,
                          toqueSelecionado,
                        );
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

  Future<Map<String, String>?> _abrirModalToque(
      BuildContext context,
      String toqueAtual,
      ) async {
    // Mapeamento label → assetName
    final toques = [
      {'label': 'Toque 1', 'assetName': 'toque_1'},
      {'label': 'Toque 2', 'assetName': 'toque_2'},
      {'label': 'Toque 3', 'assetName': 'toque_3'},
      {'label': 'Toque 4', 'assetName': 'toque_4'},
      {'label': 'Toque 5', 'assetName': 'toque_5'},
      {'label': 'Toque 6', 'assetName': 'toque_6'},
      {'label': 'Toque 7', 'assetName': 'toque_7'},
    ];

    final player = AudioPlayer();
    String? selecionado = toqueAtual;
    String? tocandoAtual; // qual toque está tocando agora

    return await showModalBottomSheet<Map<String, String>>(
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Toque do alarme",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: selecionado != null
                              ? () async {
                            await player.stop();
                            final toque = toques.firstWhere(
                                  (t) => t['assetName'] == selecionado,
                            );
                            if (context.mounted) {
                              Navigator.pop(context, toque);
                            }
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF7941D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Selecionar",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: toques.length,
                      itemBuilder: (_, index) {
                        final toque = toques[index];
                        final assetName = toque['assetName']!;
                        final label = toque['label']!;
                        final isSelected = assetName == selecionado;
                        final isTocando = assetName == tocandoAtual;

                        return GestureDetector(
                          onTap: () =>
                              setModalState(() => selecionado = assetName),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFF9E6)
                                  : const Color(0xFFFFFDE7),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                  color: const Color(0xFFF7941D), width: 2)
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? const Color(0xFFF7941D)
                                        : Colors.black87,
                                  ),
                                ),
                                // Botão play/stop
                                GestureDetector(
                                  onTap: () async {
                                    if (isTocando) {
                                      await player.stop();
                                      setModalState(
                                              () => tocandoAtual = null);
                                    } else {
                                      await player.stop();
                                      await player.play(
                                        AssetSource('audio/$assetName.mp3'),
                                      );
                                      setModalState(
                                              () => tocandoAtual = assetName);
                                      // Para automaticamente ao terminar
                                      player.onPlayerComplete.listen((_) {
                                        if (mounted) {
                                          setModalState(
                                                  () => tocandoAtual = null);
                                        }
                                      });
                                    }
                                  },
                                  child: Icon(
                                    isTocando
                                        ? Icons.stop_circle_outlined
                                        : Icons.play_circle_outline,
                                    color: isSelected
                                        ? const Color(0xFFF7941D)
                                        : Colors.grey.shade400,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() => player.dispose());
  }
}