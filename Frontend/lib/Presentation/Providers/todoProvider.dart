import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Data/DataSources/RemoteSources/noteApiService.dart';
import 'package:todo_notes/Data/DataSources/RemoteSources/notificationService.dart';
import 'package:todo_notes/Data/DataSources/RemoteSources/todoApiService.dart';
import 'package:todo_notes/Data/Repositories/noteRepo.dart';
import 'package:todo_notes/Data/Repositories/todoRepo.dart';
import 'package:todo_notes/Domain/Entities/noteEntity.dart';
import 'package:todo_notes/Domain/Entities/todoEntity.dart';
import 'package:todo_notes/Presentation/Notifiers/noteNotifier.dart';
import 'package:todo_notes/Presentation/Notifiers/todoNotifier.dart';
import 'package:todo_notes/Presentation/Providers/authProvider.dart';

//Services

final todoServiceProvider = Provider<TodoService>((ref) {
  final dio = ref.watch(dioProvider);
  return TodoService(dio: dio);
});

final noteServiceProvider = Provider<NoteService>((ref) {
  final dio = ref.watch(dioProvider);
  return NoteService(dio: dio);
});

final notiServiceProvider = Provider<Notificationservice>((ref) {
  final dio = ref.watch(dioProvider);
  return Notificationservice(dio: dio);
});

//Repositories

final todoRepoProvider = Provider<TodoRepo>((ref) {
  final api = ref.watch(todoServiceProvider);
  final notification = ref.watch(notiServiceProvider);
  return TodoRepo(api: api, notification: notification);
});

final noteRepoProvider = Provider<NoteRepo>((ref) {
  final api = ref.watch(noteServiceProvider);
  return NoteRepo(api: api);
});

final noteNotifierProvider =
    AsyncNotifierProvider<NoteNotifier, List<NoteEntity>>(NoteNotifier.new);

//--------------- non read provider-----------------------
final todoNotifierProvider =
    AsyncNotifierProvider<TodoNotifier, List<TodoEntity>>(TodoNotifier.new);

//------------------- read provider--------------------------
final todoReadNotifierProvider =
    AsyncNotifierProvider<TodoReadNotifier, List<TodoReadEntity>>(
      TodoReadNotifier.new,
    );
