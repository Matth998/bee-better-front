import 'package:flutter/material.dart';

class MultiSelectQuestionPage extends StatefulWidget {
  final String question;
  final String subtitle;
  final List<String> options;
  final Function(List<String>) onOptionSelected;

  const MultiSelectQuestionPage({
    super.key,
    required this.question,
    required this.subtitle,
    required this.options,
    required this.onOptionSelected,
  });

  @override
  State<MultiSelectQuestionPage> createState() => _MultiSelectQuestionPageState();
}

class _MultiSelectQuestionPageState extends State<MultiSelectQuestionPage> {
  // Conjunto para armazenar as opções marcadas
  final Set<String> _selectedOptions = {};

  void _toggleOption(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Image.asset('assets/images/abelha_login.png', height: 80),
        const SizedBox(height: 20),
        Text(
          widget.question,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          widget.subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFF7941D), fontSize: 16),
        ),
        const SizedBox(height: 40),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F8F8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.options.length,
                    itemBuilder: (context, index) {
                      final option = widget.options[index];
                      final isSelected = _selectedOptions.contains(option);

                      return _buildSelectableButton(option, isSelected);
                    },
                  ),
                ),

                // Botão de Próximo fixo embaixo
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _selectedOptions.isNotEmpty
                      ? () => widget.onOptionSelected(_selectedOptions.toList()) // ← passa a lista
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7941D),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Próximo",
                    style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableButton(String text, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _toggleOption(text),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF7941D).withOpacity(0.2) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFF7941D) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child:
                  Text(text, style: const TextStyle(fontSize: 17, color: Colors.black87)),
              ),
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? const Color(0xFFF7941D) : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}