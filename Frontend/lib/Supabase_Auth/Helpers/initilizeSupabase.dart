import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_notes/Core/ENV/env.dart';

Future<void> initSupabase() async {
  // Wrap main() in Future<void>
  // Wrap myApp() in ProviderScope for riverpod sync.

  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
}
