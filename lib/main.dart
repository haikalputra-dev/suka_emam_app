import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';   // <- penting
import 'firebase_options.dart';
import 'features/auth/sign_in_page.dart';
import 'features/home/home_page.dart';
import 'features/main/main_page.dart';

/// GANTI dengan Web Client ID dari Firebase (oauth client_type = 3 di google-services.json)
const String kWebClientId =

    '228865824711-7otj0c7chtq7iaf2dhl4cfqh2ugs4jci.apps.googleusercontent.com';
    // "228865824711-j12egudj0ud5dnlreeb88jgrdqc4lnut.apps.googleusercontent.com";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // v7.x: set serverClientId sekali di awal (Android butuh ini supaya dapat idToken)
  await GoogleSignIn.instance.initialize(serverClientId: kWebClientId);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SukaEmam',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF2E7D32)),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // Jika sudah login, arahkan ke MainPage, bukan HomePage
        return snap.data == null ? const SignInPage() : const MainPage();
      },
    );
  }
}

