import 'package:flutter/material.dart';

/// Card para Seleção do Responsável (Quem aplicou) e Campo de Observações Livres.
class AuthorAndNotesCard extends StatelessWidget {
  final String selectedAuthor;
  final List<String> availableAuthors;
  final TextEditingController notesCtrl;
  final bool includeNotes;
  final ValueChanged<String?> onAuthorChanged;

  const AuthorAndNotesCard({
    super.key,
    required this.selectedAuthor,
    required this.availableAuthors,
    required this.notesCtrl,
    required this.includeNotes,
    required this.onAuthorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('👤', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text('Quem está anotando?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: selectedAuthor,
            decoration: const InputDecoration(labelText: 'Responsável pelo cuidado'),
            items: availableAuthors
                .map((a) => DropdownMenuItem(value: a, child: Text(a, style: const TextStyle(fontSize: 12))))
                .toList(),
            onChanged: onAuthorChanged,
          ),

          if (includeNotes) ...[
            const SizedBox(height: 10),
            TextField(
              controller: notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Observações para o médico / diário livre',
                hintText: 'ex: Tosse piorou após brincar no parquinho',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
