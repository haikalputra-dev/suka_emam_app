import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/profile/models/checkin_history_item.dart';
import 'package:suka_emam_app/features/profile/services/profile_service.dart';
import 'package:intl/intl.dart'; // Package untuk format tanggal

class CheckinHistoryPage extends StatefulWidget {
  const CheckinHistoryPage({super.key});

  @override
  State<CheckinHistoryPage> createState() => _CheckinHistoryPageState();
}

class _CheckinHistoryPageState extends State<CheckinHistoryPage> {
  late Future<List<CheckinHistoryItem>> _historyFuture;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _historyFuture = _profileService.getCheckinHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Check-in'),
      ),
      body: FutureBuilder<List<CheckinHistoryItem>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat riwayat: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Anda belum memiliki riwayat check-in.'));
          }

          final history = snapshot.data!;

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              final date = DateTime.parse(item.checkinTime);
              final formattedDate = DateFormat('d MMMM yyyy, HH:mm').format(date);

              return ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(item.restaurant.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(formattedDate),
                trailing: Text(
                  '+${item.pointsEarned} Poin',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  // TODO: Navigasi ke halaman detail restoran jika diperlukan
                },
              );
            },
          );
        },
      ),
    );
  }
}
