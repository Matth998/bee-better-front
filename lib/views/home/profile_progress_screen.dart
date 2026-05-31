import 'package:bee_better_flutter/constants.dart';
import 'package:bee_better_flutter/services/user_session.dart';
import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

const Color beeBetterYellow = Color(0xFFFFD100);
const Color beeBetterOrange = Color(0xFFF7941D);
const Color beeBetterBrown = Color(0xFF3D2B1F);
const Color beeBetterGreyConfig = Color(0xFF4A4A4A);

class ProfileProgressScreen extends StatefulWidget {
  const ProfileProgressScreen({super.key});

  @override
  State<ProfileProgressScreen> createState() => _ProfileProgressScreenState();
}

class _ProfileProgressScreenState extends State<ProfileProgressScreen> {
  static const String _baseUrl = AppConfig.baseUrl;
  final ImagePicker _picker = ImagePicker();

  DateTime _mesAtual = DateTime(DateTime.now().year, DateTime.now().month, 1);
  Set<String> _diasComLogin = {};
  bool _loadingStreak = true;

  @override
  void initState() {
    super.initState();
    _fetchStreak();
  }

  Future<void> _fetchStreak() async {
    setState(() => _loadingStreak = true);
    try {
      final start = _mesAtual;
      final end = DateTime(_mesAtual.year, _mesAtual.month + 1, 0);
      final startStr =
          '${start.year}-${start.month.toString().padLeft(2, '0')}-01';
      final endStr =
          '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/daily-progress/history/${UserSession.id}?start=$startStr&end=$endStr'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _diasComLogin = data.map((d) {
            final date = d['date'];
            if (date is List) {
              final year = date[0];
              final month = date[1].toString().padLeft(2, '0');
              final day = date[2].toString().padLeft(2, '0');
              return '$year-$month-$day';
            }
            return date.toString();
          }).toSet();
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar streak: $e');
    } finally {
      setState(() => _loadingStreak = false);
    }
  }

  String _nomeMes(int mes) {
    const nomes = [
      '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return nomes[mes];
  }

  bool _tevLogin(int dia) {
    final dateStr =
        '${_mesAtual.year}-${_mesAtual.month.toString().padLeft(2, '0')}-${dia.toString().padLeft(2, '0')}';
    return _diasComLogin.contains(dateStr);
  }

  List<int> _getDiasExibidos() {
    final hoje = DateTime.now();
    final diasNoMes =
        DateTime(_mesAtual.year, _mesAtual.month + 1, 0).day;
    final diaBase = (_mesAtual.year == hoje.year &&
        _mesAtual.month == hoje.month)
        ? hoje.day
        : diasNoMes ~/ 2;

    final dias = <int>[];
    for (int i = -3; i <= 3; i++) {
      final dia = diaBase + i;
      if (dia >= 1 && dia <= diasNoMes) dias.add(dia);
    }
    return dias;
  }

  Future<void> _onProfilePictureTap() async {
    final hasFoto = UserSession.fotoPerfil.isNotEmpty;
    if (hasFoto) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Ver foto'),
                onTap: () {
                  Navigator.pop(context);
                  _verFoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Mudar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _escolherFoto();
                },
              ),
            ],
          ),
        ),
      );
    } else {
      _escolherFoto();
    }
  }

  void _verFoto() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(UserSession.fotoPerfil, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Future<void> _escolherFoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (image == null) return;
    await _uploadFoto(File(image.path));
  }

  Future<void> _uploadFoto(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '$_baseUrl/users/${UserSession.id}/profile-picture'),
      );
      request.headers['Authorization'] = 'Bearer ${UserSession.token}';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('Upload response: ${response.body}');

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final json = jsonDecode(response.body);
        debugPrint('campos: ${json.keys}');
        setState(() {
          UserSession.fotoPerfil = '$_baseUrl${json['profilePictureUrl']}';
        });
      }
    } catch (e) {
      debugPrint('Erro ao fazer upload: $e');
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                    BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildProfileCard(),
                          const SizedBox(height: 20),
                          _buildProgressStrip(),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _buildActionCardWrapper(
                                onTap: () =>
                                    Navigator.pushNamed(context, '/shop'),
                                gradient: const LinearGradient(
                                  begin: Alignment(-1.0, -1.0),
                                  end: Alignment(1.0, 1.0),
                                  colors: [
                                    Color(0xFFFFF4C2),
                                    Color(0xFFF5A623)
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'LOJA',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6B4219),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Image.asset('assets/images/colmeia_padrao.png',
                                        height: 60),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),
                              _buildActionCardWrapper(
                                onTap: () => Navigator.pushNamed(
                                    context, '/settings'),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        'assets/images/engrenagem_bg.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Center(
                                      child: Image.asset(
                                        'assets/images/engrenagem_icon.png',
                                        height: 70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // CARD VESTIÁRIO
                          _buildVestiarioCard(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/alarms');
          if (index == 1) Navigator.pushNamed(context, '/calendar');
          if (index == 4) Navigator.pushNamed(context, '/home');
          if (index == 3) Navigator.pushNamed(context, '/featuresScreen');
        },
      ),
    );
  }

  // ── Profile card com XP e Nível ──
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: beeBetterYellow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _onProfilePictureTap,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border:
                Border.all(color: const Color(0xFFD4AF37), width: 3),
                image: DecorationImage(
                  image: UserSession.fotoPerfil.isNotEmpty
                      ? NetworkImage(UserSession.fotoPerfil)
                      : const AssetImage('assets/images/abelha_login.png')
                  as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _buildInfoField(Icons.person, UserSession.nome),
                const SizedBox(height: 8),
                _buildInfoField(Icons.cake, UserSession.dataNascimento),
                const SizedBox(height: 8),
                // XP e Nível
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.black54, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Nível ${UserSession.nivel}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${UserSession.experiencia} xp',
                        style: const TextStyle(
                          fontSize: 13,
                          color: beeBetterOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Streak strip ──
  Widget _buildProgressStrip() {
    final diasExibidos = _getDiasExibidos();
    final hoje = DateTime.now();
    final esMesAtual =
        _mesAtual.year == hoje.year && _mesAtual.month == hoje.month;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: beeBetterBrown,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _mesAtual =
                        DateTime(_mesAtual.year, _mesAtual.month - 1, 1);
                  });
                  _fetchStreak();
                },
                child: const Icon(Icons.chevron_left,
                    color: Color(0xFFC0A68A), size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EAC8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_nomeMes(_mesAtual.month)} ${_mesAtual.year}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: beeBetterBrown),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _mesAtual =
                        DateTime(_mesAtual.year, _mesAtual.month + 1, 1);
                  });
                  _fetchStreak();
                },
                child: const Icon(Icons.chevron_right,
                    color: Color(0xFFC0A68A), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _loadingStreak
              ? const SizedBox(
            height: 45,
            child: Center(
              child: CircularProgressIndicator(
                  color: beeBetterOrange, strokeWidth: 2),
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: diasExibidos.map((dia) {
              final temLogin = _tevLogin(dia);
              final eHoje = esMesAtual && dia == hoje.day;
              return _buildDayItem(
                dia: dia,
                isFlame: temLogin,
                isToday: eHoje,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem({
    required int dia,
    bool isFlame = false,
    bool isToday = false,
  }) {
    return Column(
      children: [
        Text(
          dia.toString(),
          style: TextStyle(
            fontSize: 10,
            color: isToday ? beeBetterOrange : const Color(0xFFC0A68A),
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 35,
          height: 45,
          decoration: BoxDecoration(
            color: isToday
                ? const Color(0xFFFFE066)
                : const Color(0xFFFDF5E1),
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: beeBetterOrange, width: 1.5)
                : null,
          ),
          child: Center(
            child: isFlame
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('+5',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: beeBetterOrange)),
                Icon(Icons.local_fire_department,
                    color: beeBetterOrange, size: 18),
              ],
            )
                : const Icon(Icons.circle,
                color: Color(0xFFD4D4D4), size: 10),
          ),
        ),
      ],
    );
  }

  // ── Card Vestiário ──
  Widget _buildVestiarioCard() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/cloakroom'),
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/vestiario.png',
                fit: BoxFit.cover,
              ),
              // Overlay escuro leve para o texto ficar legível
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'VESTIÁRIO',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCardWrapper({
    required Widget child,
    LinearGradient? gradient,
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4)),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}