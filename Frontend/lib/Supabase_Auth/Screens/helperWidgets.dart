
// // google auth loading
//     final isLoading = ref.watch(googleAuthLoadingProvider);



// // 👇 Loading overlay (conditionally shown)
//               if (isLoading)
//                 Positioned.fill(
//                   child: AbsorbPointer( ------------------------------  for google auth after loading.
//                     absorbing: true,
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
//                       child: Container(
//                         color: Colors.black.withOpacity(0.2),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const LinearProgressIndicator(color: Colors.blue),
//                             const SizedBox(height: 16),
//                             Text(
//                               'Signing you in…',
//                               style: Theme.of(context).textTheme.headlineMedium,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),


