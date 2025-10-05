import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/profile/services/profile_service.dart';
import 'package:suka_emam_app/features/restaurants/models/review.dart';
import 'package:suka_emam_app/features/restaurants/widgets/review_card.dart';

class ReviewHistoryPage extends StatefulWidget {
  const ReviewHistoryPage({super.key});

  @override
  State<ReviewHistoryPage> createState() => _ReviewHistoryPageState();
}

class _ReviewHistoryPageState extends State<ReviewHistoryPage> {
  late Future<List<Review>> _reviewsFuture;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _profileService.getReviewHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Ulasan'),
      ),
      body: FutureBuilder<List<Review>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat riwayat: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Anda belum pernah memberikan ulasan.'));
          }

          final reviews = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: reviews.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tampilkan nama restoran di atas setiap kartu ulasan
                  Text(
                    review.restaurant?.name ?? 'Nama Restoran Tidak Tersedia',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Gunakan kembali ReviewCard yang sudah ada
                  ReviewCard(review: review),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
