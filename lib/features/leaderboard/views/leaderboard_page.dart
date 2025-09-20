// lib/features/leaderboard/views/leaderboard_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:suka_emam_app/features/leaderboard/models/leaderboard_user.dart';
import 'package:suka_emam_app/features/leaderboard/services/leaderboard_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Papan Peringkat'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mingguan'),
            Tab(text: 'Bulanan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LeaderboardList(period: 'weekly'),
          LeaderboardList(period: 'monthly'),
        ],
      ),
    );
  }
}

// Widget terpisah untuk menampilkan daftar leaderboard
class LeaderboardList extends StatefulWidget {
  final String period;
  const LeaderboardList({required this.period, super.key});

  @override
  State<LeaderboardList> createState() => _LeaderboardListState();
}

class _LeaderboardListState extends State<LeaderboardList> {
  late Future<List<LeaderboardUser>> _leaderboardFuture;
  final LeaderboardService _service = LeaderboardService();

  Timer? _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
    _startCountdown();
  }
  
  @override
  void dispose() {
    _timer?.cancel(); // Sangat penting untuk membatalkan timer
    super.dispose();
  }

  void _fetchLeaderboard() {
    _leaderboardFuture = _service.getLeaderboard(period: widget.period);
  }

  void _startCountdown() {
    // Batalkan timer lama jika ada untuk mencegah kebocoran memori
    _timer?.cancel(); 

    final now = DateTime.now();
    DateTime endTime;

    if (widget.period == 'weekly') {
      // Temukan hari Senin berikutnya, lalu kurangi 1 detik untuk mendapatkan Minggu 23:59:59
      final daysUntilNextMonday = 8 - now.weekday;
      final nextMonday = DateTime(now.year, now.month, now.day + daysUntilNextMonday);
      endTime = nextMonday.subtract(const Duration(seconds: 1));
    } else { // monthly
      // Temukan hari pertama bulan berikutnya, lalu kurangi 1 detik
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      endTime = nextMonth.subtract(const Duration(seconds: 1));
    }

    // Jalankan timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = endTime.difference(DateTime.now());
      if (mounted) { // Pastikan widget masih ada di tree sebelum update state
        if (remaining.isNegative) {
          setState(() => _timeRemaining = Duration.zero);
          timer.cancel();
        } else {
          setState(() => _timeRemaining = remaining);
        }
      } else {
        // Jika widget sudah tidak ada, hentikan timer
        timer.cancel();
      }
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _fetchLeaderboard();
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = twoDigits(duration.inDays);
    final hours = twoDigits(duration.inHours.remainder(24));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$days : $hours : $minutes : $seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // [BARU] Countdown Timer
        Container(
          width: double.infinity,
          color: Colors.grey[200],
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(
                'Berakhir Dalam',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDuration(_timeRemaining),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ],
          ),
        ),
        // Daftar Leaderboard
        Expanded(
          child: FutureBuilder<List<LeaderboardUser>>(
            future: _leaderboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Belum ada data peringkat.'));
              }

              final users = snapshot.data!;

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    // [MODIFIKASI] Tampilan item di daftar
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Text('#${index + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(width: 12),
                            RandomAvatar(username: user.name),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  SocialMediaIcons(user: user),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${user.periodPoints} Poin', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// [BARU] Widget untuk avatar random
class RandomAvatar extends StatelessWidget {
  final String username;
  const RandomAvatar({required this.username, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.blue, Colors.green, Colors.red, Colors.purple, Colors.teal, Colors.deepOrange];
    final color = colors[username.hashCode % colors.length];
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return CircleAvatar(
      backgroundColor: color,
      child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}


// Widget untuk ikon media sosial
class SocialMediaIcons extends StatelessWidget {
  final LeaderboardUser user;
  const SocialMediaIcons({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (user.instagramUsername != null)
          SizedBox(
            height: 24, width: 24,
            child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.camera_alt, size: 18, color: Colors.pink), onPressed: () => _launchSocialMediaUrl('https://www.instagram.com/${user.instagramUsername}')),
          ),
        if (user.tiktokUsername != null)
          SizedBox(
            height: 24, width: 24,
            child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.music_note, size: 18, color: Colors.black), onPressed: () => _launchSocialMediaUrl('https://www.tiktok.com/@${user.tiktokUsername}')),
          ),
      ],
    );
  }

  Future<void> _launchSocialMediaUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print('Could not launch $url');
    }
  }
}