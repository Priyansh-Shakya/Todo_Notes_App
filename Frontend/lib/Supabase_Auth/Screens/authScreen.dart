import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Presentation/Screens/globalUtils.dart';
import 'package:todo_notes/Supabase_Auth/Logic/authProvider.dart';

final isLogInModeProvider = StateProvider((ref) => true);

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscurePass = true;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    /// 👇 NEW: Login / SignUp toggle
    bool isLogin = ref.watch(isLogInModeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(isLogin ? "Welcome Back" : "Create Account"),
        centerTitle: true,
        elevation: 0,
      ),
      body: auth.when(
        data: (session) {
          if (session != null) {
            final email = session.user.email ?? session.user.id;
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Logged in as $email",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(authNotifierProvider.notifier).signOut(),
                    child: const Text("Sign Out"),
                  ),
                ],
              ),
            );
          }

          // ---- LOGIN / SIGNUP UI -----
          return Stack(
            children: [
              // 👇 Your existing UI (unchanged)
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    children: [
                      _buildAuthCard(context),
                      const SizedBox(height: 24),
                      _buildGoogleBtn(),
                      const SizedBox(height: 12),
                      // _buildFacebookBtn(), // You can uncomment this when you implement Facebook login
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const ShimmerLoadingWidget(),
        error: (_, __) => Center(child: Text('Something went wrong.')),
      ),
    );
  }

  // --------------------------
  // LOGIN / SIGNUP CARD
  // --------------------------
  Widget _buildAuthCard(BuildContext context) {
    bool isLogin = ref.watch(isLogInModeProvider);
    final notifier = ref.watch(authNotifierProvider.notifier);
    final formError = notifier.formError;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black26,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isLogin ? "Login" : "Create Account",
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // EMAIL FIELD
          TextField(
            controller: emailCtrl,
            decoration: InputDecoration(
              labelText: "Email",
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              prefixIcon: const Icon(Icons.email_outlined),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.blueAccent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              // filled: true,
              // fillColor: Colors.black54,
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // PASSWORD FIELD
          TextField(
            controller: passCtrl,
            obscureText: obscurePass,
            decoration: InputDecoration(
              labelText: "Password",
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.blueAccent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              // filled: true,
              // fillColor: Colors.black54,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePass ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => obscurePass = !obscurePass);
                },
              ),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 5),
          Text(
            'Choose a strong password',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.green),
          ),
          const SizedBox(height: 25),

          if (formError != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: Text(
                formError,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // SUBMIT BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitAuth,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                isLogin ? "Sign In" : "Sign Up",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // MODE SWITCH
          TextButton(
            onPressed: () => setState(
              () => ref.read(isLogInModeProvider.notifier).state = !isLogin,
            ),
            child: Text(
              isLogin
                  ? "Don't have an account? Create one"
                  : "Already have an account? Sign In",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                decorationColor: Colors.blue,
                decorationThickness: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------
  // BUTTONS
  // --------------------------
  Widget _buildGoogleBtn() {
    return OutlinedButton.icon(
      icon: Image.asset('assets/images/google_logo.png', width: 24, height: 24),
      label: Text(
        "Continue with Google",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
      onPressed: () =>
          ref.read(authNotifierProvider.notifier).signInWithGoogle(),
    );
  }

  Widget _buildFacebookBtn() {
    return OutlinedButton.icon(
      icon: const Icon(Icons.facebook, color: Colors.blue, size: 24),
      label: Text(
        "Continue with Facebook",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
      onPressed: () {},
    );
  }

  // --------------------------
  // COMBINED LOGIN / SIGNUP HANDLER
  // --------------------------
  Future<void> _submitAuth() async {
    bool isLogin = ref.watch(isLogInModeProvider);
    final notifier = ref.read(authNotifierProvider.notifier);
    final data = (email: emailCtrl.text.trim(), pass: passCtrl.text.trim());

    if (isLogin) {
      await notifier.signInWithEmail(data);
    } else {
      debugPrint("Sigining Up with EMAIL: ${data.email}");
      await notifier.signUpWithEmail(data);
      debugPrint("Creating user for EMAIL: ${data.email}");
    }
  }
}
