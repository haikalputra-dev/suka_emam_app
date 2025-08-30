import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../ping/ping_repo.dart';
import '../scan/scan_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${user?.displayName ?? user?.email ?? "User"}'),
        actions: [
          IconButton(
            onPressed: () async => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScanPage()));
            },
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan QR',
          ),
        ],
      ),
      body: const Center(child: Text('Home — klik tombol di kanan bawah untuk test API')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          try {
            final msg = await PingRepo().ping();
            messenger.showSnackBar(SnackBar(content: Text('Ping OK: $msg')));
          } catch (e) {
            messenger.showSnackBar(SnackBar(content: Text('Ping gagal: $e')));
          }
        },
        label: const Text('Test API'),
        icon: const Icon(Icons.wifi_tethering),
      ),
    );
  }
}
