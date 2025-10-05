import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/auth/auth_service.dart';

// Nama kelas sekarang benar: SignInPage
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Fungsi generik untuk menangani proses login
  void _handleLogin(Future<void> Function() loginMethod) async {
    setState(() => _isLoading = true);
    try {
      await loginMethod();
      // Navigasi akan ditangani secara otomatis oleh StreamBuilder di main.dart
    } catch (e) {
      // Menampilkan pesan error jika login dibatalkan atau gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text('Sign in', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const Text('Please sign in to continue', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 100), // Beri ruang lebih
              
              // Tampilkan loading indicator jika sedang proses
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('Or continue with'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tombol Google
                        _buildSocialButton(
                          onPressed: () => _handleLogin(_authService.signInWithGoogle),
                          assetPath: 'assets/images/google.png', // Pastikan path ini benar
                        ),
                        
                        const SizedBox(width: 20),
                        // Tombol Facebook
                        _buildSocialButton(
                          onPressed: () => _handleLogin(_authService.signInWithFacebook),
                          assetPath: 'assets/images/facebook.png', // Pastikan path ini benar
                        ),
                      ],
                    ),
                  ],
                ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper untuk membuat tombol sosial media
  Widget _buildSocialButton({required VoidCallback onPressed, required String assetPath}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(assetPath, height: 40),
      ),
    );
  }
}
