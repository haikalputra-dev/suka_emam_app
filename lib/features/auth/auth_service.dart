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
    final user = await GoogleSignIn.instance.authenticate(); // returns GoogleSignInAccount
    // Ambil token untuk Firebase
    final tokens = await user.authentication; // v7: cuma ada idToken
    final credential = GoogleAuthProvider.credential(idToken: tokens.idToken);
    await _auth.signInWithCredential(credential);
  }

}
