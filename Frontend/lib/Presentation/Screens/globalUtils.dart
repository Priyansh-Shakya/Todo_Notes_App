//* Shared global widgets and refresh helpers
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo_notes/Core/Connectivity/checkInternet.dart';
import 'package:todo_notes/Core/appBootstrap.dart';

class ShimmerLoadingWidget extends StatefulWidget {
  const ShimmerLoadingWidget({super.key});

  @override
  State<ShimmerLoadingWidget> createState() => _ShimmerLoadingWidgetState();
}

class _ShimmerLoadingWidgetState extends State<ShimmerLoadingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmer;
  late final Animation<double> _dotPulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _shimmer = Tween<double>(
      begin: -1.5,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _dotPulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Shimmer card
          AnimatedBuilder(
            animation: _shimmer,
            builder: (context, child) {
              return Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: scheme.surfaceContainerHighest,
                  border: Border.all(
                    color: scheme.outlineVariant.withOpacity(0.5),
                    width: 0.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      child!,
                      // Shimmer sweep
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(_shimmer.value - 0.5, 0),
                              end: Alignment(_shimmer.value + 0.5, 0),
                              colors: [
                                Colors.white.withOpacity(0),
                                Colors.white.withOpacity(0.18),
                                Colors.white.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 32,
                color: scheme.onSurface.withOpacity(0.25),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Pulsing dots
          AnimatedBuilder(
            animation: _dotPulse,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final offset = i * 0.2;
                  final t = (_dotPulse.value + offset) % 1.0;
                  final opacity = 0.3 + 0.7 * sin(t * pi).clamp(0.0, 1.0);
                  final scale = 0.8 + 0.2 * sin(t * pi).clamp(0.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.onSurface.withOpacity(opacity * 0.4),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

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

void showRefreshNoInternetBanner() {
  final messenger = rootScaffoldMessengerKey.currentState;
  if (messenger == null) return; // not mounted yet, bail safely

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
    showRefreshNoInternetBanner();
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
