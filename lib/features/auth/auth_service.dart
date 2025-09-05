import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User?> authChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signInEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> registerEmail(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> sendReset(String email) => _auth.sendPasswordResetEmail(email: email);

  Future<void> signOut() => _auth.signOut();

  // --- Google ---
  Future<void> signInWithGoogle() async {
    // Mulai flow sign-in interaktif
    final googleUser = await GoogleSignIn.instance.authenticate();

    // --- BAGIAN PENTING: CEK JIKA USER MEMBATALKAN ---
    if (googleUser == null) {
      // User membatalkan proses login, jangan lanjutkan.
      print('Google sign in dibatalkan oleh user.');
      // Lempar error agar bisa ditangkap di UI jika perlu
      throw Exception('Proses login dibatalkan');
    }
    // --------------------------------------------------

  // Ambil token untuk Firebase
  final googleAuth = await googleUser.authentication;
  final credential = GoogleAuthProvider.credential(
    idToken: googleAuth.idToken,
  );

  // Masuk ke Firebase dengan kredensial Google
  await _auth.signInWithCredential(credential);
  }

}
