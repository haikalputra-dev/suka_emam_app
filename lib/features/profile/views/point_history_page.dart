import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/profile/models/point_history_item.dart';
import 'package:suka_emam_app/features/profile/services/profile_service.dart';
import 'package:intl/intl.dart';

class PointHistoryPage extends StatefulWidget {
  const PointHistoryPage({super.key});

  @override
  State<PointHistoryPage> createState() => _PointHistoryPageState();
}

class _PointHistoryPageState extends State<PointHistoryPage> {
  late Future<List<PointHistoryItem>> _historyFuture;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _historyFuture = _profileService.getPointHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Poin'),
      ),
      body: FutureBuilder<List<PointHistoryItem>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat riwayat: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Anda belum memiliki riwayat perolehan poin.'));
          }

          final history = snapshot.data!;

          return ListView.separated(
            itemCount: history.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = history[index];
              final date = DateTime.parse(item.createdAt);
              final formattedDate = DateFormat('d MMMM yyyy, HH:mm').format(date);

              return ListTile(
                leading: const Icon(Icons.star_outline, color: Colors.amber),
                title: Text(item.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(formattedDate),
                trailing: Text(
                  '+${item.points} Poin',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
