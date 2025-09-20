// lib/features/profile/profile_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/auth/auth_service.dart';
import 'package:suka_emam_app/features/profile/models/user_profile.dart' as profile_models;
import 'package:suka_emam_app/features/profile/services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? _currentUser = AuthService().currentUser;
  late Future<profile_models.UserProfile> _profileFuture;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _profileFuture = _profileService.getProfile();
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _profileFuture = _profileService.getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              // Aksi untuk mengedit profil
            },
          ),
        ],
      ),
      body: FutureBuilder<profile_models.UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Gagal memuat profil: ${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Data profil tidak ditemukan.'));
          }

          final userProfile = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Bagian Header Profil (Dinamis) ---
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: (_currentUser?.photoURL != null)
                          ? NetworkImage(_currentUser!.photoURL!)
                          : null,
                      child: (_currentUser?.photoURL == null)
                          ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentUser?.displayName ?? userProfile.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // --- [BARU] Menampilkan Level Pengguna ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Level ${userProfile.level}',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // --- Batas Penambahan Level ---
                    
                    const SizedBox(height: 4),
                    Text(
                      _currentUser?.email ?? userProfile.email,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    // --- Bagian Badges (Dinamis) ---
                    _buildBadgesSection(userProfile.badges),
                    const SizedBox(height: 24),

                    // --- Bagian Statistik Gamifikasi (Dinamis) ---
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(horizontal: 0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Total Badges', userProfile.totalBadges.toString()),
                            _buildStatItem('Total Scores', userProfile.totalPoints.toString()),
                            _buildStatItem('Total Reviews', userProfile.totalReviews.toString()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- Bagian Menu Item ---
                    _buildMenuItem(context, Icons.history, 'Check-in History', () {}),
                    _buildMenuItem(context, Icons.bookmark_border, 'Favorites', () {}),
                    _buildMenuItem(context, Icons.settings_outlined, 'Settings', () {}),
                    _buildMenuItem(context, Icons.logout, 'Logout', () async {
                      await AuthService().signOut();
                    }, isLogout: true),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- [MODIFIKASI] Helper untuk menampilkan badge dinamis ---
  Widget _buildBadgesSection(List<profile_models.Badge> badges) {
    // Cari badge level (asumsi namanya mengandung kata 'Level' atau 'Tier')
    final levelBadge = badges.firstWhere(
      (b) => b.name.toLowerCase().contains('level') || b.name.toLowerCase().contains('tier'),
      orElse: () => profile_models.Badge.empty(), // Kembalikan badge kosong jika tidak ada
    );
    
    // Cari badge achievement terbaru (selain badge level)
    final achievementBadge = badges.reversed.firstWhere(
      (b) => !b.name.toLowerCase().contains('level') && !b.name.toLowerCase().contains('tier'),
      orElse: () => profile_models.Badge.empty(), // Kembalikan badge kosong jika tidak ada
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBadgeItem("Level Badge", levelBadge),
        _buildBadgeItem("Last Achievement", achievementBadge),
      ],
    );
  }

  // --- [BARU] Helper untuk membuat satu item badge ---
  Widget _buildBadgeItem(String title, profile_models.Badge badge) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (badge.imageUrl.isEmpty)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shield_outlined, size: 50, color: Colors.grey[400]),
          )
        else
          Tooltip(
            message: "${badge.name}\n${badge.description}",
            child: Image.network(
              badge.imageUrl,
              width: 100,
              height: 100,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const CircularProgressIndicator(),
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.shield_outlined, size: 50, color: Colors.grey),
            ),
          ),
      ],
    );
  }


  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: isLogout ? Colors.red : Colors.grey[700]),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: isLogout ? Colors.red : Colors.grey[800],
            ),
          ),
          trailing: isLogout ? null : const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        ),
        const Divider(height: 1),
      ],
    );
  }
}