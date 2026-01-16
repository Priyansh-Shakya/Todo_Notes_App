import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Domain/Entities/noteEntity.dart';
import 'package:todo_notes/Presentation/Providers/todoProvider.dart';

class CreateNote extends ConsumerStatefulWidget {
  const CreateNote({super.key});

  @override
  ConsumerState<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends ConsumerState<CreateNote> {
  final titleCtr = TextEditingController();
  final contentCtr = TextEditingController();
  bool isPinned = false;

  Future<void> createNote() async {
    // 1) Build a NoteEntity — UI is allowed to create domain entities
    final note = NoteEntity(
      id: 0, // or nothing if optional
      title: titleCtr.text,
      content: contentCtr.text,
      pinned: isPinned,
      createdAt: DateTime.now().toString(),
    );

    // 2) Call notifier (business logic)
    await ref.read(noteNotifierProvider.notifier).writeNote(note: note);

    // 3) Navigate back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Note",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() => isPinned = !isPinned);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isPinned ? "Pinned" : "Unpinned",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
            icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined),
          ),
          IconButton(onPressed: createNote, icon: Icon(Icons.check)),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtr,
              decoration: InputDecoration(labelText: "Title"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: contentCtr,
              decoration: InputDecoration(labelText: "Content"),
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }
}
