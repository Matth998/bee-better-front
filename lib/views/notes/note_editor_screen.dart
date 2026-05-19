import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bee_better_flutter/services/user_session.dart';

class NoteEditorScreen extends StatefulWidget {
  final Map<String, dynamic>? note;
  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _saving = false;
  bool _checklistMode = false;
  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: _isEditing ? widget.note!['title'] : '',
    );
    _contentController = TextEditingController(
      text: _isEditing ? widget.note!['content'] : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // ───── Auto-save ─────

  // Celular: gesto/botão físico de voltar
  Future<bool> _onWillPop() async {
    await _save();
    return true;
  }

  // Desktop/botão <: salva e faz pop explícito
  Future<void> _saveAndPop() async {
    await _save();
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) return;

    debugPrint('Salvando nota — userId: ${UserSession.id}');

    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await http.put(
          Uri.parse('http://localhost:8080/notes/${widget.note!['id']}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${UserSession.token}',
          },
          body: jsonEncode({
            'title': title,
            'description': content,
            'userId': UserSession.id,
          }),
        );
      } else {
        await http.post(
          Uri.parse('http://localhost:8080/notes'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${UserSession.token}',
          },
          body: jsonEncode({
            'title': title,
            'description': content,
            'userId': UserSession.id,
          }),
        );
      }
    } catch (e) {
      debugPrint('Erro ao salvar nota: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ───── Checklist ─────

  void _toggleChecklist() {
    final text = _contentController.text;
    final sel = _contentController.selection;

    if (!sel.isValid || sel.isCollapsed) {
      final pos = sel.isValid ? sel.baseOffset : text.length;
      final before = text.substring(0, pos);
      final after = text.substring(pos);
      final lineStart = before.lastIndexOf('\n') + 1;
      final currentLine = before.substring(lineStart);

      if (currentLine.startsWith('- [ ] ') ||
          currentLine.startsWith('- [x] ')) {
        final newBefore = before.substring(0, lineStart) +
            currentLine.replaceFirst(RegExp(r'^- \[.\] '), '');
        _contentController.value = TextEditingValue(
          text: newBefore + after,
          selection: TextSelection.collapsed(offset: newBefore.length),
        );
        setState(() => _checklistMode = false);
      } else {
        const insert = '- [ ] ';
        final newText = before + insert + after;
        _contentController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: pos + insert.length),
        );
        setState(() => _checklistMode = true);
      }
      return;
    }

    final selected = text.substring(sel.start, sel.end);
    final lines = selected.split('\n');
    final allChecklist = lines.every(
          (l) => l.startsWith('- [ ] ') || l.startsWith('- [x] '),
    );
    final newLines = lines.map((l) {
      if (allChecklist) return l.replaceFirst(RegExp(r'^- \[.\] '), '');
      return (l.startsWith('- [ ] ') || l.startsWith('- [x] '))
          ? l
          : '- [ ] $l';
    }).join('\n');

    final newText =
        text.substring(0, sel.start) + newLines + text.substring(sel.end);
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: sel.start,
        extentOffset: sel.start + newLines.length,
      ),
    );
    setState(() => _checklistMode = !allChecklist);
  }

  void _onContentChanged(String value) {
    if (!_checklistMode) return;
    final sel = _contentController.selection;
    if (!sel.isValid || !sel.isCollapsed) return;
    final pos = sel.baseOffset;
    if (pos < 1) return;

    if (value.substring(pos - 1, pos) == '\n') {
      final before = value.substring(0, pos);
      final after = value.substring(pos);
      final lines = before.split('\n');
      final prevLine = lines.length >= 2 ? lines[lines.length - 2] : '';

      if (prevLine.startsWith('- [ ] ') || prevLine.startsWith('- [x] ')) {
        if (prevLine == '- [ ] ' || prevLine == '- [x] ') {
          final newBefore =
          before.substring(0, before.lastIndexOf('- [ ] \n'));
          _contentController.value = TextEditingValue(
            text: newBefore + '\n' + after,
            selection:
            TextSelection.collapsed(offset: newBefore.length + 1),
          );
          setState(() => _checklistMode = false);
          return;
        }
        const insert = '- [ ] ';
        final newText = before + insert + after;
        _contentController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: pos + insert.length),
        );
      }
    }
  }

  // ───── Marca-texto ─────

  void _toggleHighlight() {
    final text = _contentController.text;
    final sel = _contentController.selection;
    if (!sel.isValid || sel.isCollapsed) return;

    final selected = text.substring(sel.start, sel.end);
    final isHighlighted = selected.startsWith('==') &&
        selected.endsWith('==') &&
        selected.length > 4;

    final String newSelected;
    if (isHighlighted) {
      newSelected = selected.substring(2, selected.length - 2);
    } else {
      newSelected = '==$selected==';
    }

    final newText =
        text.substring(0, sel.start) + newSelected + text.substring(sel.end);
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: sel.start,
        extentOffset: sel.start + newSelected.length,
      ),
    );
  }

  // ───── build ─────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop, // ← celular: gesto/botão físico
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildMeta(),
              const Divider(height: 1, color: Colors.black12),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: 12,
                  ),
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    onChanged: _onContentChanged,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Escreva sua anotação...',
                      hintStyle: TextStyle(color: Colors.black38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: _saveAndPop, // ← desktop e celular: salva e volta
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF7941D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                hintText: 'Título',
                hintStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_saving)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFF7941D),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMeta() {
    final now = DateTime.now();
    const months = [
      '',
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    final dateStr = _isEditing
        ? widget.note!['date'] ?? '${now.day} de ${months[now.month]}'
        : '${now.day} de ${months[now.month]}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Text(
            dateStr,
            style: const TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 12, color: Colors.black26),
          const SizedBox(width: 12),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _contentController,
            builder: (_, val, __) => Text(
              '${val.text.length} Caracteres',
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 72,
      color: const Color(0xFFF7941D),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ToolButton(
            icon: Icons.check_box_outlined,
            active: _checklistMode,
            tooltip: 'Lista de tarefas',
            onTap: _toggleChecklist,
          ),
          _ToolButton(
            icon: Icons.border_color_outlined,
            active: false,
            tooltip: 'Marca-texto',
            onTap: _toggleHighlight,
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.active,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: active
                ? Colors.white.withOpacity(0.35)
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border:
            active ? Border.all(color: Colors.white, width: 1.5) : null,
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}