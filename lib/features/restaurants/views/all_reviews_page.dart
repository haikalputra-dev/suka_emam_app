import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/restaurants/models/review.dart';
import 'package:suka_emam_app/features/restaurants/services/restaurant_service.dart';
import 'package:suka_emam_app/features/restaurants/widgets/review_card.dart';

class AllReviewsPage extends StatefulWidget {
  final int restaurantId;
  final String restaurantName;

  const AllReviewsPage({
    super.key, 
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  final RestaurantService _restaurantService = RestaurantService();
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    // Panggil API untuk mengambil semua ulasan
    _reviewsFuture = _restaurantService.getReviewsForRestaurant(widget.restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ulasan untuk ${widget.restaurantName}'),
      ),
      body: FutureBuilder<List<Review>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat ulasan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada ulasan untuk restoran ini.'));
          }

          final reviews = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return ReviewCard(review: reviews[index]);
            },
            separatorBuilder: (context, index) => const Divider(height: 24),
          );
        },
      ),
    );
  }
}
