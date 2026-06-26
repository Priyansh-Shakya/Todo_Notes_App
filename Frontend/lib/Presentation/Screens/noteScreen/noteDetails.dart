import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Domain/Entities/noteEntity.dart';
import 'package:todo_notes/Presentation/Providers/todoProvider.dart';
import 'package:todo_notes/Presentation/Screens/globalUtils.dart';

class NoteDetails extends ConsumerStatefulWidget {
  final int noteId;
  final bool isPinned;
  const NoteDetails({super.key, required this.noteId, required this.isPinned});

  @override
  ConsumerState<NoteDetails> createState() => _NoteDetailsState();
}

class _NoteDetailsState extends ConsumerState<NoteDetails> {
  late TextEditingController titleCtr;
  late TextEditingController contentCtr;

  bool isEditMode = false;
  bool localPinned = false;

  @override
  void initState() {
    super.initState();
    titleCtr = TextEditingController();
    contentCtr = TextEditingController();
    localPinned = widget.isPinned;
  }

  @override
  void dispose() {
    titleCtr.dispose();
    contentCtr.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() => isEditMode = !isEditMode);
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(noteNotifierProvider);

    return notesAsync.when(
      loading: () => const Scaffold(body: ShimmerLoadingWidget()),
      error: (e, st) => Scaffold(body: Center(child: Text("Error: $e"))),
      data: (notes) {
        final note = notes.firstWhere(
          (n) => n.id == widget.noteId,
          orElse: () => NoteEntity(
            id: -1,
            title: "",
            content: "",
            pinned: false,
            createdAt: DateTime.now().toString(),
          ),
        );

        // Only set controller text if not in edit mode
        // This prevents overwriting user edits
        if (!isEditMode) {
          titleCtr.text = note.title;
          contentCtr.text = note.content;
        }

        return Scaffold(
          appBar: AppBar(
            title: isEditMode
                ? TextField(
                    controller: titleCtr,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green, // The color when focused
                          width: 2.0, // The thickness when focused
                        ),
                      ),
                      border: InputBorder.none,
                    ),
                    style: Theme.of(context).textTheme.headlineMedium,
                    cursorColor: Theme.of(context).colorScheme.onSurface,
                  )
                : Text(
                    note.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.push_pin,
                  color: localPinned ? Colors.amber : Colors.grey,
                ),
                onPressed: () {
                  if (isEditMode) {
                    setState(() {
                      localPinned = !localPinned;
                      debugPrint("Pinned :$localPinned");
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Enable Edit mode for toggling Pin',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: isEditMode
                    ? TextField(
                        controller: contentCtr,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        cursorColor: Theme.of(context).colorScheme.onSurface,
                      )
                    : Text(
                        note.content,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(
              isEditMode ? Icons.check : Icons.edit,
              color: Colors.blue,
            ),
            onPressed: () async {
              if (isEditMode) {
                // Save edits
                final updated = note.copyWith(
                  id: note.id,
                  title: titleCtr.text,
                  content: contentCtr.text,
                  pinned: localPinned,
                );
                print(
                  "id: ${updated.id}\ntitle:${updated.title}\ncontent:${updated.content}",
                );
                await ref
                    .read(noteNotifierProvider.notifier)
                    .updateNote(id: note.id, note: updated);
              }
              _toggleEdit();
            },
          ),
        );
      },
    );
  }
}
