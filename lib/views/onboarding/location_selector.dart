import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'dart:convert';

class LocationSelector extends StatefulWidget {
  final Function(String state, String city) onNext;
  const LocationSelector({super.key, required this.onNext});

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  List<dynamic> states = [];
  List<dynamic> cities = [];
  String? selectedState;
  String? selectedStateName; // ← adicionado
  String? selectedCity;
  bool loadingCities = false;

  @override
  void initState() {
    super.initState();
    _fetchStates();
  }

  Future<void> _fetchStates() async {
    final response = await http.get(Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados?orderBy=nome'));
    if (response.statusCode == 200) {
      setState(() => states = json.decode(response.body));
    }
  }

  Future<void> _fetchCities(String uf) async {
    setState(() {
      loadingCities = true;
      selectedCity = null;
      cities = [];
    });
    final response = await http.get(Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$uf/municipios'));
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
        Image.asset('assets/images/abelha_login.png', height: 80),
        const SizedBox(height: 20),
        const Text("De onde você é?",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text("Selecione sua localização",
            style: TextStyle(color: Color(0xFFF7941D))),
        const SizedBox(height: 40),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F8F8),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                // DROPDOWN DE ESTADOS COM BUSCA
                DropdownSearch<String>(
                  items: (filter, loadProps) => states.map((e) => e['nome'].toString()).toList(),
                  selectedItem: selectedStateName, // ← atualizado
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: "Estado",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: "Buscar estado...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  onSelected: (val) {
                    if (val == null) return;
                    final uf = states.firstWhere((e) => e['nome'] == val)['sigla'];
                    setState(() {
                      selectedState = uf;
                      selectedStateName = val; // ← adicionado
                    });
                    _fetchCities(uf);
                  },
                ),
                const SizedBox(height: 20),

                // DROPDOWN DE CIDADES COM BUSCA
                DropdownSearch<String>(
                  enabled: selectedState != null && !loadingCities,
                  items: (filter, loadProps) => cities.map((e) => e['nome'].toString()).toList(),
                  selectedItem: selectedCity,
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: loadingCities ? "Carregando..." : "Cidade",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: "Buscar cidade...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  onSelected: (val) => setState(() => selectedCity = val),
                ),

                const Spacer(),

                ElevatedButton(
                  onPressed: selectedCity != null
                      ? () => widget.onNext(selectedState!, selectedCity!)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7941D),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Próximo",
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}