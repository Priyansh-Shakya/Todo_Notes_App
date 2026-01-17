import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Supabase_Auth/Logic/authProvider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscurePass = true;

  /// 👇 NEW: Login / SignUp toggle
  bool isLogin = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

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
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  _buildAuthCard(context),
                  const SizedBox(height: 24),
                  _buildGoogleBtn(),
                  const SizedBox(height: 12),
                  _buildFacebookBtn(), // 👈 kept exactly as you said!
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text("Auth Error: $err")),
      ),
    );
  }

  // --------------------------
  // LOGIN / SIGNUP CARD
  // --------------------------
  Widget _buildAuthCard(BuildContext context) {
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
              // labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              //   color: const Color.fromARGB(255, 209, 208, 208),
              // ),
              prefixIcon: const Icon(Icons.email_outlined),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.blueAccent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              
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
              // labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              //   color: const Color.fromARGB(255, 209, 208, 208),
              // ),
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.blueAccent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              

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
          const SizedBox(height: 15),

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
            onPressed: () => setState(() => isLogin = !isLogin),
            child: Text(
              isLogin
                  ? "Don't have an account? Create one"
                  : "Already have an account? Sign In",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                decorationColor: const Color.fromARGB(255, 5, 119, 212),
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
    final notifier = ref.read(authNotifierProvider.notifier);

    print(emailCtrl.text);
    print(passCtrl.text);

    final data = (email: emailCtrl.text.trim(), pass: passCtrl.text.trim());

    try {
      if (isLogin) {
        await notifier.signInWithEmail(data);
      } else {
        await notifier.signUpWithEmail(data);
      }
    } catch (_) {}
  }
}
