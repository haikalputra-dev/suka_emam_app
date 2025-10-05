import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:suka_emam_app/core/dio_client.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User?> authChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Metode untuk sign out, diperbarui untuk menyertakan Facebook
  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }

  // --- GOOGLE (Dengan Penanganan Error & Sinkronisasi) ---
  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) {
        throw Exception('Proses login Google dibatalkan');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      await _syncUserToBackend(userCredential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception('Akun sudah ada dengan metode login lain.');
      }
      rethrow; // Lempar ulang error lain
    }
  }

  // --- FACEBOOK (Dengan Penanganan Error & Notifikasi Sederhana) ---
  Future<void> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'], // Meminta izin email
    );

    if (result.status == LoginStatus.success) {
      final AccessToken accessToken = result.accessToken!;
      final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.token);

      try {
        // Coba login seperti biasa
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
                final User? user = userCredential.user;

        // --- [LOGIKA BARU] Ambil dan perbarui foto profil ---
        if (user != null) {
          // 1. Minta data pengguna dari Facebook, termasuk URL foto ukuran 200px
          final userData = await FacebookAuth.instance.getUserData(
            fields: "name,email,picture.width(200)",
          );
          
          final String? facebookPhotoUrl = userData['picture']?['data']?['url'];

          // 2. Jika Firebase belum punya foto atau fotonya beda, perbarui
          if (facebookPhotoUrl != null && user.photoURL != facebookPhotoUrl) {
            await user.updatePhotoURL(facebookPhotoUrl);
            await user.reload(); // Muat ulang data user untuk memastikan perubahan diterapkan
          }
        }
        await _syncUserToBackend(userCredential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // Jika error terjadi, cukup beri tahu pengguna dengan informasi umum
          String errorMessage = 'Email ini sudah terdaftar dengan metode login lain. ';
          
          // Coba dapatkan informasi provider dari credential yang konflik
          if (e.credential != null) {
            errorMessage += 'Silakan login menggunakan metode yang sudah Anda gunakan sebelumnya.';
          } else {
            errorMessage += 'Silakan gunakan Google Sign-In atau metode login lain yang pernah Anda gunakan.';
          }
          
          throw Exception(errorMessage);
        } else {
          // Lempar ulang error Firebase lainnya
          rethrow;
        }
      }
    } else {
      throw Exception('Login dengan Facebook gagal atau dibatalkan.');
    }
  }
  
  // Metode terpusat untuk sinkronisasi ke backend
  Future<void> _syncUserToBackend(UserCredential userCredential) async {
    final user = userCredential.user;
    if (user == null) return;
    final idToken = await user.getIdToken(true);
    await DioClient.syncUser(idToken!);
  }
}

