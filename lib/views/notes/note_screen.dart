import 'package:bee_better_flutter/views/menu/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // Anotações fake por enquanto
  final List<Map<String, dynamic>> notes = [
    {
      'title': 'Lorem ipsum',
      'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Dolor in aute consequat qui fugiat ipsum tempor sit excepteur.',
      'date': '11 de novembro',
    },
    {
      'title': 'Lorem ipsum',
      'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      'date': '11 de novembro',
    },
    {
      'title': 'Lorem ipsum',
      'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Dolor in aute consequat qui fugiat ipsum tempor sit excepteur.',
      'date': '11 de novembro',
    },
    {
      'title': 'Lorem ipsum',
      'content': 'Lorem ipsum dolor sit amet.',
      'date': '11 de novembro',
    },
    {
      'title': 'Lorem ipsum',
      'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Dolor in aute consequat.',
      'date': '11 de novembro',
    },
    {
      'title': 'Lorem ipsum',
      'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Dolor in aute consequat qui fugiat ipsum tempor sit excepteur. Mais um parágrafo aqui.',
      'date': '11 de novembro',
    },
    {
      'title': 'Lorem ipsum',
      'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      'date': '11 de novembro',
    },
    {
      'title': 'Lorem ipsum',
      'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Dolor in aute consequat qui fugiat ipsum tempor sit excepteur.',
      'date': '11 de novembro',
    },
    {
      'title': 'Lorem ipsum',
      'content': 'Lorem ipsum dolor sit amet.',
      'date': '11 de novembro',
    },
    {
      'title': 'Lorem ipsum',
      'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Dolor in aute consequat qui fugiat ipsum.',
      'date': '11 de novembro',
    },
  ];

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
                // HEADER
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

                // GRID MASONRY
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildMasonryGrid(),
                  ),
                ),
              ],
            ),
          ),

          // BOTÃO +
          Positioned(
            bottom: 90,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {},
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
        },
      ),
    );
  }

  Widget _buildMasonryGrid() {
    // Divide as notas em duas colunas alternando
    final leftColumn = <Map<String, dynamic>>[];
    final rightColumn = <Map<String, dynamic>>[];

    for (int i = 0; i < notes.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(notes[i]);
      } else {
        rightColumn.add(notes[i]);
      }
    }

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // COLUNA ESQUERDA
          Expanded(
            child: Column(
              children: leftColumn
                  .map((note) => _buildNoteCard(note))
                  .toList(),
            ),
          ),
          const SizedBox(width: 10),
          // COLUNA DIREITA
          Expanded(
            child: Column(
              children: rightColumn
                  .map((note) => _buildNoteCard(note))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    return GestureDetector(
      onTap: () {}, // abrir anotação futuramente
      child: Container(
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
            Text(
              note['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              note['content'],
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              note['date'],
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}