import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _svc = AuthService();
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  void _toast(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  Future<void> _doRegister() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _svc.registerEmail(_email.text.trim(), _pass.text);
      // opsional: update displayName
      await FirebaseAuth.instance.currentUser?.updateDisplayName(_name.text.trim());
      _toast('Sign up success', color: Colors.green);
      if (mounted) Navigator.pop(context); // balik ke Sign in
    } on FirebaseAuthException catch (e) {
      _toast(_map(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _map(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use': return 'Email sudah terdaftar';
      case 'invalid-email': return 'Email tidak valid';
      case 'weak-password': return 'Password minimal 6 karakter';
      default: return e.message ?? 'Terjadi kesalahan';
    }
  }

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF2E7D32);
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
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
                    Text('Sign up', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    const Text('Create an Account', textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(hintText: 'Nama'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'sukaemam@example.co.id'),
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
                      validator: (v) => (v == null || v.length < 8) ? 'Password must be 8 character' : null,
                    ),
                    const SizedBox(height: 6),
                    const Text('Password must be 8 character', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: green),
                        onPressed: _loading ? null : _doRegister,
                        child: _loading ? const CircularProgressIndicator() : const Text('Sign Up'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account'),
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Sign in')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Center(child: Text('Or Continue with')),
                    const SizedBox(height: 8),
                    Center(
                      child: InkWell(
                        onTap: _loading ? null : () async {
                          try { await _svc.signInWithGoogle(); _toast('Signed in with Google', color: Colors.green); }
                          catch (e) { _toast('Google sign-in failed: $e'); }
                        },
                        borderRadius: BorderRadius.circular(28),
                        child: Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(28),
                            color: Colors.white,
                          ),
                          alignment: Alignment.center,
                          child: Image.asset('assets/google.png', width: 28, height: 28),
                        ),
                      ),
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
