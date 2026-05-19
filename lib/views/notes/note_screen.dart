import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:bee_better_flutter/views/notes/note_editor_screen.dart';
import 'package:bee_better_flutter/services/user_session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> notes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    setState(() => loading = true);
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/notes/user/${UserSession.id}'),
        headers: {'Authorization': 'Bearer ${UserSession.token}'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          notes = data.map((n) => {
            'id': n['id'],
            'title': n['title'] ?? '',
            'content': n['description'] ?? '',
            'date': _formatDate(n['createdAt']),
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar notas: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  String _formatDate(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        '', 'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
        'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
      ];
      return '${dt.day} de ${months[dt.month]}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _openEditor({Map<String, dynamic>? note}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
    );
    _fetchNotes(); // ← sempre recarrega, independente do retorno
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7941D),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.chevron_left,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: loading
                      ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFF7941D)),
                  )
                      : notes.isEmpty
                      ? const Center(
                    child: Text(
                      'Nenhuma anotação ainda.\nClique em + para criar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black54, fontSize: 16),
                    ),
                  )
                      : Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildGrid(),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 90,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => _openEditor(),
              backgroundColor: Colors.white,
              elevation: 4,
              child: const Icon(Icons.add, color: Colors.black),
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
          if (index == 5) Navigator.pushNamed(context, '/menu');
        },
      ),
    );
  }

  // Grid 50/50 com altura dinâmica por coluna
  Widget _buildGrid() {
    final left = <Map<String, dynamic>>[];
    final right = <Map<String, dynamic>>[];
    for (int i = 0; i < notes.length; i++) {
      if (i % 2 == 0) left.add(notes[i]);
      else right.add(notes[i]);
    }

    return SingleChildScrollView(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // COLUNA ESQUERDA — exatamente 50% da largura disponível
            Expanded(
              child: Column(
                children: left.map(_buildNoteCard).toList(),
              ),
            ),
            const SizedBox(width: 10),
            // COLUNA DIREITA — exatamente 50%
            Expanded(
              child: Column(
                children: right.map(_buildNoteCard).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    return GestureDetector(
      onTap: () => _openEditor(note: note),
      child: Container(
        width: double.infinity, // ocupa 100% da coluna (já é 50% da tela)
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((note['title'] as String).isNotEmpty) ...[
              Text(
                note['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
            ],
            // Preview sem maxLines — altura totalmente dinâmica
            _NotePreview(content: note['content']),
            const SizedBox(height: 10),
            Text(
              note['date'],
              style: const TextStyle(fontSize: 11, color: Colors.black38),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Preview de Markdown simples sem dependência externa
// Renderiza: ==highlight==, - [ ] e - [x] checklist
// ─────────────────────────────────────────
class _NotePreview extends StatelessWidget {
  final String content;

  const _NotePreview({required this.content});

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();

    final lines = content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) => _buildLine(line)).toList(),
    );
  }

  Widget _buildLine(String line) {
    // Checklist
    if (line.startsWith('- [ ] ') || line.startsWith('- [x] ')) {
      final checked = line.startsWith('- [x] ');
      final text = line.substring(6);
      return Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              checked ? Icons.check_box : Icons.check_box_outline_blank,
              size: 15,
              color: checked ? const Color(0xFFF7941D) : Colors.black45,
            ),
            const SizedBox(width: 5),
            Expanded(child: _buildInlineText(text, checked: checked)),
          ],
        ),
      );
    }

    // Linha normal
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: _buildInlineText(line),
    );
  }

  Widget _buildInlineText(String text, {bool checked = false}) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'==(.+?)==');
    int last = 0;

    final baseStyle = TextStyle(
      fontSize: 13,
      color: Colors.black87,
      height: 1.4,
      decoration: checked ? TextDecoration.lineThrough : null,
      decorationColor: Colors.black45,
    );

    for (final match in regex.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(
          text: text.substring(last, match.start),
          style: baseStyle,
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle.copyWith(
          backgroundColor: const Color(0xFFFFE082),
        ),
      ));
      last = match.end;
    }

    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last), style: baseStyle));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: baseStyle));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}