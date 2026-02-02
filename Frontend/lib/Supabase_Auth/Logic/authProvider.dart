import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_notes/Core/ENV/env.dart';
import 'package:todo_notes/Supabase_Auth/Logic/authNotifier.dart';
import 'package:todo_notes/Supabase_Auth/Logic/authRepo.dart';
import 'package:todo_notes/Supabase_Auth/Mock_Test/mock_auth_repo.dart';

import 'abstractRepo.dart';

// final dioProvider = Provider<Dio>((ref) {
//   final dio = Dio(
//     BaseOptions(
//       baseUrl: "Your URL",
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 15),
//       headers: {'Content-Type': 'application/json'},
//     ),
//   );
//   dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

//   dio.interceptors.add(
//     InterceptorsWrapper(
//       onRequest: (options, handler) {
//         debugPrint("🚀 Interceptor triggered!");
//         debugPrint("🚀 Headers before: ${options.headers}");
//         final token = ref.read(tokenProvider);
//         debugPrint("🚀 Token in interceptor: $token");

//         if (token != null && token.isNotEmpty) {
//           options.headers['Authorization'] = 'Bearer $token';
//         }
//         debugPrint("🚀 Headers after: ${options.headers}");
//         return handler.next(options);
//       },
//     ),
//   );

//   return dio;
// });



final googleAuthLoadingProvider = StateProvider<bool>((ref) => false);

final tokenProvider = Provider<String?>((ref) {
  final session = ref.watch(authNotifierProvider).value;
  return session?.accessToken;
});

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepoProvider = Provider<AuthenticationRepo>((ref) {
  final client = ref.watch(supabaseClientProvider);

  if (Env.useMockAuth) {
    return MockAuthRepo()
        as AuthenticationRepo; // Use mock repo if the flag is set True.
  }

  return AuthRepo(cli: client);
});

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, Session?>(
  AuthNotifier.new,
);

final userProvider = Provider<User?>((ref) {
  final session = ref.watch(authNotifierProvider).value;
  return session?.user;
});


