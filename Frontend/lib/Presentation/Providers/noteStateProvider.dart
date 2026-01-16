import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteModeProvider = StateProvider<bool>((ref) => false);
final selectedIdsProvider = StateProvider<Set<int>>((ref) => {});
