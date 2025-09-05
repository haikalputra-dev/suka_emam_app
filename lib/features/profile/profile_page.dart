// lib/features/profile/profile_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/auth/auth_service.dart'; // Asumsi auth_service ada di sini

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? _currentUser = AuthService().currentUser;

  // Untuk sekarang, data statistik dan badges ini kita buat bohongan dulu (mock)
  final int _totalBadges = 35;
  final int _totalScores = 155; // Mengganti Total Points menjadi Total Scores
  final int _totalReviews = 40;

  // Daftar path gambar mock badges
  final List<String> _mockBadges = [
    'assets/badges/first_bite.png', // Ganti dengan nama file actual badges-mu
    'assets/badges/tier_3.png',
    'assets/badges/photo_enthusiast.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Background abu-abu muda
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar transparan
        elevation: 0, // Tanpa shadow
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        //   onPressed: () {
        //     // Logika untuk kembali ke halaman sebelumnya
        //     // Navigator.of(context).pop(); // Ini akan mengarahkan ke halaman sebelumnya
        //     // Karena ini tab utama, mungkin lebih baik tidak ada tombol back
        //     // Atau, bisa juga diabaikan jika ingin tetap ada
        //   },
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              // Aksi untuk mengedit profil
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Bagian Header Profil ---
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                // Gunakan placeholder atau gambar dari _currentUser.photoURL
                backgroundImage: _currentUser?.photoURL != null
                    ? NetworkImage(_currentUser!.photoURL!)
                    : null,
                child: _currentUser?.photoURL == null
                    ? Image.asset('assets/profile_placeholder.png', // Ganti dengan placeholder sesuai desain
                                   fit: BoxFit.cover) 
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                _currentUser?.displayName ?? 'Haikal', // Tampilkan nama, atau 'Haikal'
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _currentUser?.email ?? 'haikal@sukaemam.co.id', // Tampilkan email
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // --- Bagian Badges ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _mockBadges.map((path) => Image.asset(path, width: 110, height: 110)).toList(),
              ),
              const SizedBox(height: 24),

              // --- Bagian Statistik Gamifikasi (dalam Card) ---
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(horizontal: 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Total Badges', _totalBadges.toString()),
                      _buildStatItem('Total Scores', _totalScores.toString()),
                      _buildStatItem('Total Reviews', _totalReviews.toString()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- Bagian Menu Item ---
              _buildMenuItem(context, Icons.person_outline, 'Profile', () { /* Aksi */ }),
              _buildMenuItem(context, Icons.bookmark_border, 'Favorites', () { /* Aksi */ }),
              _buildMenuItem(context, Icons.history, 'Previous Reviews', () { /* Aksi */ }),
              _buildMenuItem(context, Icons.settings_outlined, 'Settings', () { /* Aksi */ }),
              _buildMenuItem(context, Icons.logout, 'Logout', () async {
                // Aksi untuk logout
                await AuthService().signOut();
              }, isLogout: true),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper untuk menampilkan item statistik
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange), // Warna orange
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    );
  }

  // Widget helper untuk menu item
  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: isLogout ? Colors.red : Colors.grey[700]), // Ikon merah untuk logout
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: isLogout ? Colors.red : Colors.grey[800], // Teks merah untuk logout
            ),
          ),
          trailing: isLogout ? null : const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey), // Panah untuk non-logout
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        ),
        const Divider(height: 1), // Garis pemisah antar item
      ],
    );
  }
}