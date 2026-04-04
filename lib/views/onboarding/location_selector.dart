import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationSelector extends StatefulWidget {
  final VoidCallback onNext;
  const LocationSelector({super.key, required this.onNext});

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  List<dynamic> states = [];
  List<dynamic> cities = [];
  String? selectedState;
  String? selectedCity;
  bool loadingCities = false;

  @override
  void initState() {
    super.initState();
    _fetchStates();
  }

  // Busca os Estados
  Future<void> _fetchStates() async {
    final response = await http.get(Uri.parse('https://servicodados.ibge.gov.br/api/v1/localidades/estados?orderBy=nome'));
    if (response.statusCode == 200) {
      setState(() {
        states = json.decode(response.body);
      });
    }
  }

  // Busca as Cidades baseado na UF selecionada
  Future<void> _fetchCities(String uf) async {
    setState(() {
      loadingCities = true;
      selectedCity = null;
      cities = [];
    });
    final response = await http.get(Uri.parse('https://servicodados.ibge.gov.br/api/v1/localidades/estados/$uf/municipios'));
    if (response.statusCode == 200) {
      setState(() {
        cities = json.decode(response.body);
        loadingCities = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Image.network('https://i.imgur.com/lwgH7H5.png', height: 80),
        const SizedBox(height: 20),
        const Text("De onde você é?", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text("Selecione sua localização", style: TextStyle(color: Color(0xFFF7941D))),
        const SizedBox(height: 40),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F8F8),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                // DROPDOWN DE ESTADOS
                _buildDropdown(
                  label: "Estado",
                  value: selectedState,
                  items: states.map((e) => DropdownMenuItem(value: e['sigla'].toString(), child: Text(e['nome']))).toList(),
                  onChanged: (val) {
                    setState(() => selectedState = val);
                    _fetchCities(val!);
                  },
                ),
                const SizedBox(height: 20),

                // DROPDOWN DE CIDADES
                _buildDropdown(
                  label: "Cidade",
                  value: selectedCity,
                  items: cities.map((e) => DropdownMenuItem(value: e['nome'].toString(), child: Text(e['nome']))).toList(),
                  onChanged: (val) => setState(() => selectedCity = val),
                  enabled: selectedState != null && !loadingCities,
                ),

                const Spacer(),

                // Botão de Próximo (só habilita se tiver cidade selecionada)
                ElevatedButton(
                  onPressed: selectedCity != null ? widget.onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7941D),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Próximo", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({required String label, required String? value, required List<DropdownMenuItem<String>> items, required Function(String?) onChanged, bool enabled = true}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      hint: Text(loadingCities ? "Carregando..." : "Selecione"),
    );
  }
}