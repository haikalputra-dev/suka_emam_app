import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/auth/auth_service.dart';
import 'package:suka_emam_app/features/profile/models/user_profile.dart' as profile_models;
import 'package:suka_emam_app/features/profile/services/profile_service.dart';
import 'package:suka_emam_app/features/profile/views/point_history_page.dart';
import 'package:suka_emam_app/features/profile/views/checkin_history_page.dart';
import 'package:suka_emam_app/features/profile/views/review_history_page.dart';
import 'package:suka_emam_app/features/profile/views/edit_profile_page.dart';

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
          // Bungkus tombol Edit dengan FutureBuilder agar hanya muncul saat data siap
          FutureBuilder<profile_models.UserProfile>(
            future: _profileFuture,
            builder: (context, snapshot) {
              // Tampilkan tombol hanya jika data sudah berhasil dimuat
              if (snapshot.hasData) {
                return IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () {
                    // Navigasi ke halaman edit, lalu refresh saat kembali
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(userProfile: snapshot.data!),
                      ),
                    ).then((_) => _refreshProfile());
                  },
                );
              }
              // Jika data belum ada, tampilkan widget kosong
              return const SizedBox.shrink();
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
                      userProfile.name, // Menggunakan nama dari API
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

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
                    
                    const SizedBox(height: 4),
                    Text(
                      userProfile.email, // Menggunakan email dari API
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
                            _buildStatItem(
                              'Total Poin',
                              userProfile.totalPoints.toString(),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const PointHistoryPage()));
                              },
                            ),
                            _buildStatItem(
                              'Total Review',
                              userProfile.totalReviews.toString(),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewHistoryPage()));
                              },
                            ),
                            // _buildStatItem('Total Review', userProfile.totalReviews.toString()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- [PERUBAHAN] Bagian Menu Item ---
                    _buildMenuItem(context, Icons.history, 'Riwayat Check-in', () {
                      // 2. Navigasi ke halaman riwayat check-in
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckinHistoryPage()));
                    }),
                    // Menu 'Favorites' dihapus
                    _buildMenuItem(context, Icons.settings_outlined, 'Settings', () {
                      // TODO: Implementasi halaman settings
                    }),
                    _buildMenuItem(context, Icons.logout, 'Logout', () async {
                      await AuthService().signOut();
                    }, isLogout: true),
                    // ---------------------------------
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadgesSection(List<profile_models.Badge> badges) {
    final levelBadge = badges.firstWhere(
      (b) => b.name.toLowerCase().contains('level') || b.name.toLowerCase().contains('tier'),
      orElse: () => profile_models.Badge.empty(),
    );
    
    final achievementBadge = badges.reversed.firstWhere(
      (b) => !b.name.toLowerCase().contains('level') && !b.name.toLowerCase().contains('tier'),
      orElse: () => profile_models.Badge.empty(),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBadgeItem("Level Badge", levelBadge),
        _buildBadgeItem("Last Achievement", achievementBadge),
      ],
    );
  }

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

  Widget _buildStatItem(String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8), // Agar efek ripple rapi
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
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

