import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Supabase_Auth/Logic/authProvider.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      // Replace with your actual backend URL : https://todo-notes-app-backend-fastapi.onrender.com/
      //USB Debugging , Physical device URL: 'http://192.168.29.138:8000/'
      baseUrl: 

      'https://todo-notes-app-backend-fastapi.onrender.com/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final authState = await ref.read(authNotifierProvider.future);
        final token = authState?.accessToken;
        debugPrint("Access Token: $token");
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint('🔐 JWT attached');
        } else {
          debugPrint('⚠️ No JWT available');
        }

        handler.next(options);
      },
    ),
  );

  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
});
