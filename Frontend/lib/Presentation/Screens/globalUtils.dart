//* Shared global widgets and refresh helpers
import 'package:flutter/material.dart';
import 'package:todo_notes/Core/Connectivity/checkInternet.dart';

//? Generic error widget for AsyncValue error branches
Widget showSomethingWentWrongWidget({String? errorDetails}) {
  final String? message = errorDetails?.split('\n').first;

  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 72, color: Colors.red.shade700),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          if (message != null && message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
        ],
      ),
    ),
  );
}

void showRefreshNoInternetBanner(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearMaterialBanners();
  messenger.showMaterialBanner(
    MaterialBanner(
      content: const Text(
        'No internet connection. Pull to refresh again.',
        style: TextStyle(color: Colors.white),
      ),
      leading: const Icon(Icons.wifi_off_rounded, color: Colors.white),
      backgroundColor: Colors.red.shade600,
      actions: [
        TextButton(
          onPressed: messenger.clearMaterialBanners,
          child: const Text('OK', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  Future.delayed(const Duration(seconds: 3), messenger.clearMaterialBanners);
}

Future<void> refreshScreenWithInternetCheck(
  BuildContext context,
  Future<void> Function() refreshAction,
) async {
  final bool isConnected = await checkInternetConnection();
  if (!isConnected) {
    showRefreshNoInternetBanner(context);
    return;
  }

  await refreshAction();
}

// Wrap any non-scrollable child (or scrollable) with a RefreshIndicator
// so pull-to-refresh works even when the content is empty or an error occurred.
Widget wrapWithRefresh(
  BuildContext context,
  Widget child,
  Future<void> Function() onRefresh,
) {
  return RefreshIndicator(
    onRefresh: onRefresh,
    child: LayoutBuilder(
      builder: (ctx, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        );
      },
    ),
  );
}
