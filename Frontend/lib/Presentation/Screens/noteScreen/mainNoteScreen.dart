import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Core/AppSounds/soundManager.dart';
import 'package:todo_notes/Presentation/Providers/noteStateProvider.dart';
import 'package:todo_notes/Presentation/Providers/todoProvider.dart';
import 'package:todo_notes/Presentation/Screens/globalUtils.dart';
import 'package:todo_notes/Presentation/Screens/noteScreen/createNote.dart';
import 'package:todo_notes/Presentation/Screens/noteScreen/noteDetails.dart';

class MainNoteScreen extends ConsumerWidget {
  const MainNoteScreen({super.key});

  // -------------------------
  // helpers (LEFT UNTOUCHED)
  // -------------------------
  String createdAtSliced(String? timeString) {
    // If null or empty, use current time
    final time = (timeString != null && timeString.isNotEmpty)
        ? DateTime.tryParse(timeString)
        : DateTime.now();

    final t = time ?? DateTime.now(); // fallback if parsing fails

    final day = t.day.toString().padLeft(2, '0');
    final month = t.month.toString().padLeft(2, '0');
    final year = t.year.toString();

    return '$day/$month/$year';
  }

  int numberOfLines(String content) => content.split('\n').length;

  String slicedTask(String content) {
    final splited = content.split("\n");
    if (splited.length <= 3) return content;
    return "${splited[0]}\n${splited[1]}\n${splited[2]}\n...";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(noteNotifierProvider);
    final notifier = ref.read(noteNotifierProvider.notifier);
    final isDeleteMode = ref.watch(deleteModeProvider);
    final selectedIds = ref.watch(selectedIdsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: Text("Notes", style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
        actions: [
          if (isDeleteMode && selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                SoundManager.playDeleteSound();
                await ref
                    .read(noteNotifierProvider.notifier)
                    .deleteNote(ids: selectedIds.toList());

                ref.read(deleteModeProvider.notifier).state = false;
                ref.read(selectedIdsProvider.notifier).state = {};
              },
            ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const ShimmerLoadingWidget(),
        error: (e, st) => wrapWithRefresh(
          context,
          showSomethingWentWrongWidget(errorDetails: e.toString()),
          () => notifier.refreshList(),
        ),
        data: (notes) {
          if (notes.isEmpty) {
            return wrapWithRefresh(
              context,
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sticky_note_2_outlined,
                      size: 96,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withAlpha(68),
                    ),
                    Text(
                      "No Notes yet, create new",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
              () => notifier.refreshList(),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              return refreshScreenWithInternetCheck(
                context,
                () => notifier.refreshList(),
              );
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notes.length,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.80, // tweak to adjust card height
              ),
              itemBuilder: (context, index) {
                final note = notes[index];
                final isSelected = selectedIds.contains(note.id);
                debugPrint("Pinned: ${note.pinned}");

                return GestureDetector(
                  onTap: () {
                    if (isDeleteMode) {
                      _toggleSelection(ref, note.id);
                    } else {
                      debugPrint(
                        "id:${note.id}\ntitle:${note.title}\ncontent:${note.content}",
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetails(
                            noteId: note.id,
                            isPinned: note.pinned,
                          ),
                        ),
                      );
                    }
                  },
                  onLongPress: () {
                    ref.read(deleteModeProvider.notifier).state = true;
                    _toggleSelection(ref, note.id);
                  },
                  child: Card(
                    elevation: 6,

                    color: isSelected
                        ? Colors.blue.withOpacity(0.3)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.title,
                                style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Text(
                                  (numberOfLines(note.content) > 3)
                                      ? slicedTask(note.content)
                                      : note.content,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    createdAtSliced(note.createdAt),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .color!
                                              .withOpacity(0.5),
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (note.pinned)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              Icons.push_pin,
                              color: Color(0xFFFFD700),
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, size: 30, color: Colors.blue),
        onPressed: () {
          SoundManager.playPopUpSound();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateNote()),
          );
        },
      ),
    );
  }

  void _toggleSelection(WidgetRef ref, int id) {
    final selected = ref.read(selectedIdsProvider);
    final newSet = {...selected};

    newSet.contains(id) ? newSet.remove(id) : newSet.add(id);

    ref.read(selectedIdsProvider.notifier).state = newSet;

    // Auto-disable delete mode if nothing selected
    if (newSet.isEmpty) {
      ref.read(deleteModeProvider.notifier).state = false;
    }
  }
}
