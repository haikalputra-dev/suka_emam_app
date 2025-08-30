import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _svc = AuthService();
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  void _toast(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  Future<void> _doEmail() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _svc.signInEmail(_email.text.trim(), _pass.text);
      _toast('Sign in success', color: Colors.green);
      // TODO: navigate to Home
    } on FirebaseAuthException catch (e) {
      _toast(_map(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _doGoogle() async {
    setState(() => _loading = true);
    try {
      await _svc.signInWithGoogle();
      _toast('Signed in with Google', color: Colors.green);
      // TODO: navigate to Home
    } catch (e) {
      _toast('Google sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _map(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email': return 'Email tidak valid';
      case 'user-not-found': return 'Akun tidak ditemukan';
      case 'wrong-password': return 'Password salah';
      default: return e.message ?? 'Terjadi kesalahan';
    }
  }

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF2E7D32);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text('Sign in', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    const Text('Please sign in to continue', textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'haikal@sukaemam.co.id'),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Masukkan email valid' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pass,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: '**********',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6) ? 'Min 6 karakter' : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _loading ? null : () async {
                          final email = _email.text.trim();
                          if (!email.contains('@')) return _toast('Masukkan email valid');
                          try {
                            await _svc.sendReset(email);
                            _toast('Link reset dikirim ke $email', color: Colors.green);
                          } catch (e) { _toast('Gagal kirim reset: $e'); }
                        },
                        child: const Text('Forget Password?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: green),
                        onPressed: _loading ? null : _doEmail,
                        child: _loading ? const CircularProgressIndicator() : const Text('Sign In'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: _loading ? null : () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignUpPage()));
                          },
                          child: const Text('Sign up'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Center(child: Text('Or continue with')),
                    const SizedBox(height: 8),
                    Center(
                      child: 
                        InkWell(
                          onTap: _loading ? null : () async {
                            setState(() => _loading = true);
                            try {
                              await AuthService().signInWithGoogle();
                              // AuthGate akan auto-redirect ke Home
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Google sign-in failed: $e')),
                              );
                            } finally {
                              if (mounted) setState(() => _loading = false);
                            }
                          },
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(28),
                              color: Colors.white,
                            ),
                            alignment: Alignment.center,
                            child: Image.asset('assets/google.png', width: 28, height: 28),
                          ),
                        )

                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
