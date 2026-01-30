import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_notes/Supabase_Auth/Logic/authProvider.dart';
import 'package:todo_notes/main.dart';

class Bootstrap extends ConsumerStatefulWidget {
  const Bootstrap({super.key});

  @override
  ConsumerState<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends ConsumerState<Bootstrap> {
  late final StreamSubscription<AuthState> _sub;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _session = Supabase.instance.client.auth.currentSession;
    final state = ref.read(authNotifierProvider.notifier).authStateChange();

    _sub = state.listen((data) {
      setState(() {
        _session = data.session;
      });
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scopeKey = _session?.user.id ?? 'unauthenticated';

    return ProviderScope(key: ValueKey(scopeKey), child: const MyApp());
  }
}
