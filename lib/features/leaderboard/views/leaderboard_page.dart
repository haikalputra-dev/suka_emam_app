import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // <-- 1. Import package SVG
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
    _timer?.cancel();
    super.dispose();
  }

  void _fetchLeaderboard() {
    _leaderboardFuture = _service.getLeaderboard(period: widget.period);
  }

  void _startCountdown() {
    _timer?.cancel(); 
    final now = DateTime.now();
    DateTime endTime;
    if (widget.period == 'weekly') {
      final daysUntilNextMonday = 8 - now.weekday;
      final nextMonday = DateTime(now.year, now.month, now.day + daysUntilNextMonday);
      endTime = nextMonday.subtract(const Duration(seconds: 1));
    } else {
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      endTime = nextMonth.subtract(const Duration(seconds: 1));
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = endTime.difference(DateTime.now());
      if (mounted) {
        if (remaining.isNegative) {
          setState(() => _timeRemaining = Duration.zero);
          timer.cancel();
        } else {
          setState(() => _timeRemaining = remaining);
        }
      } else {
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

  // --- [BARU] Fungsi untuk menentukan warna berdasarkan peringkat ---
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFF2CC); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFFFE6CC); // Bronze
      default:
        return Colors.white; // Warna default
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                    final rank = index + 1;
                    return Card(
                      color: _getRankColor(rank), // <-- Terapkan warna di sini
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Text('#$rank', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
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

class SocialMediaIcons extends StatelessWidget {
  final LeaderboardUser user;
  const SocialMediaIcons({required this.user, super.key});

  Widget _buildSocialIcon({
    required String assetPath,
    String? url,
  }) {
    final bool isEnabled = url != null && url.isNotEmpty;
    // Bungkus dengan Opacity untuk memberi efek samar saat nonaktif
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.12,
      child: IconButton(
        padding: const EdgeInsets.only(right: 6.0),
        constraints: const BoxConstraints(),
        icon: SvgPicture.asset(
          assetPath,
          height: 30,
        ),
        onPressed: isEnabled ? () => _launchSocialMediaUrl(url) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSocialIcon(
          assetPath: 'assets/images/instagram.svg',
          url: user.instagramUsername != null ? 'https://www.instagram.com/${user.instagramUsername}' : null,
        ),
        _buildSocialIcon(
          assetPath: 'assets/images/tiktok.svg',
          url: user.tiktokUsername != null ? 'https://www.tiktok.com/@${user.tiktokUsername}' : null,
        ),
        _buildSocialIcon(
          assetPath: 'assets/images/facebook-svg.svg',
          url: user.facebookProfileUrl,
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
