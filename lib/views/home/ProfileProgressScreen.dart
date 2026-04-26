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

  final ImagePicker _picker = ImagePicker(); // ← adicionado

  @override
  void initState() {
    super.initState();
  }

  // Todos os métodos de foto adicionados aqui
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
    print('Abrindo galeria...');
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    print('Imagem selecionada: ${image?.path}');
    if (image == null) {
      print('Nenhuma imagem selecionada');
      return;
    }
    print('Chamando upload...');
    await _uploadFoto(File(image.path));
  }

  Future<void> _uploadFoto(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:8080/users/${UserSession.id}/profile-picture'),
      );
      request.headers['Authorization'] = 'Bearer ${UserSession.token}';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse); // ← converte aqui

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final json = jsonDecode(response.body);
        setState(() {
          UserSession.fotoPerfil = 'http://localhost:8080${json['profilePictureUrl']}';
        });
      }
    } catch (e) {
      print('Erro ao fazer upload: $e');
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
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildProfileCard(),
                          _buildProgressStrip(),
                          Row(
                            children: [
                              _buildActionCardWrapper(
                                gradient: const LinearGradient(
                                  begin: Alignment(-1.0, -1.0),
                                  end: Alignment(1.0, 1.0),
                                  colors: [Color(0xFFFFF4C2), Color(0xFFF5A623)],
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
                                    Image.asset('assets/images/colmeia.png', height: 60),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),
                              _buildActionCardWrapper(
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

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: beeBetterYellow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          // ← GestureDetector adicionado na foto
          GestureDetector(
            onTap: _onProfilePictureTap,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                image: DecorationImage(
                  image: UserSession.fotoPerfil.isNotEmpty
                      ? NetworkImage(UserSession.fotoPerfil)
                      : const AssetImage('assets/images/abelha_login.png'),
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
                const SizedBox(height: 10),
                _buildInfoField(Icons.cake, UserSession.dataNascimento),
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
          Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildProgressStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: beeBetterBrown,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF4EAC8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Novembro 2025',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: beeBetterBrown),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(Icons.chevron_left, color: Color(0xFFC0A68A), size: 20),
              _buildDayItem(isFlame: true),
              _buildDayItem(isFlame: true),
              _buildDayItem(isFlame: true),
              _buildDayItem(isCoin: true),
              _buildDayItem(isDot: true),
              _buildDayItem(isDot: true),
              _buildDayItem(isDot: true),
              const Icon(Icons.chevron_right, color: Color(0xFFC0A68A), size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem({bool isFlame = false, bool isCoin = false, bool isDot = false}) {
    Widget content = const SizedBox();
    Color bgColor = const Color(0xFFFDF5E1);

    if (isFlame) {
      content = const Icon(Icons.local_fire_department, color: beeBetterOrange, size: 22);
    } else if (isCoin) {
      bgColor = const Color(0xFFFFE066);
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('+5', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: beeBetterBrown)),
          Icon(Icons.circle, color: beeBetterOrange, size: 14),
        ],
      );
    } else {
      content = const Icon(Icons.circle, color: Color(0xFFD4D4D4), size: 10);
    }

    return Container(
      width: 35,
      height: 45,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Center(child: content),
    );
  }

  Widget _buildActionCardWrapper({
    required Widget child,
    LinearGradient? gradient,
    Color? backgroundColor,
  }) {
    return Expanded(
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}