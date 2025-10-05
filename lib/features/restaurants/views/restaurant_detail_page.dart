import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/restaurants/models/restaurant.dart' as restaurant_models;
import 'package:suka_emam_app/features/restaurants/views/all_reviews_page.dart';
import 'package:suka_emam_app/features/restaurants/models/review.dart';
import 'package:suka_emam_app/features/restaurants/services/restaurant_service.dart';
import 'package:suka_emam_app/features/restaurants/widgets/review_card.dart';
import 'package:url_launcher/url_launcher.dart';

// 1. Ubah menjadi StatefulWidget
class RestaurantDetailPage extends StatefulWidget {
  final restaurant_models.Restaurant restaurant;

  const RestaurantDetailPage({super.key, required this.restaurant});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  // 2. Tambahkan state untuk memuat data ulasan
  final RestaurantService _restaurantService = RestaurantService();
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    // 3. Panggil API untuk mengambil ulasan saat halaman pertama kali dibuka
    _reviewsFuture = _restaurantService.getReviewsForRestaurant(widget.restaurant.id);
  }

  Future<void> _launchMapsUrl(BuildContext context) async {
    final lat = widget.restaurant.latitude;
    final lng = widget.restaurant.longitude;
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // LAPISAN 1: GAMBAR BACKGROUND
          Positioned(
            top: 0, left: 0, right: 0,
            child: CachedNetworkImage(
              imageUrl: widget.restaurant.mainImageUrl,
              fit: BoxFit.cover,
              height: screenHeight * 0.45,
              width: screenWidth,
              placeholder: (context, url) => Container(color: Colors.grey[300]),
              errorWidget: (context, url, error) => const Icon(Icons.hide_image),
            ),
          ),

          // LAPISAN 2: KONTEN PUTIH YANG BISA DI-SCROLL
          Positioned.fill(
            top: screenHeight * 0.4,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.restaurant.name,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Expanded(child: Text(widget.restaurant.shortAddress, style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis,)),
                        const SizedBox(width: 16),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(widget.restaurant.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Row(
                    //   children: [
                    //     const Icon(Icons.price_change_outlined, color: Colors.grey, size: 16),
                    //     const SizedBox(width: 4),
                    //     Text(widget.restaurant.priceInfo, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    //   ],
                    // ),

                    const Divider(height: 32),
                  
                    const Text('Gallery', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const SizedBox(height: 32),
                    const Text('About Restaurant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                      widget.restaurant.description,
                      style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 16),
                    ),

                    const Divider(height: 32),
                                       Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ulasan Pengguna', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            // Navigasi ke halaman baru untuk semua ulasan
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => AllReviewsPage(
                                restaurantId: widget.restaurant.id,
                                restaurantName: widget.restaurant.name,
                              ),
                            ));
                          }, 
                          child: const Text('Lihat semua'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<Review>>(
                      future: _reviewsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Gagal memuat ulasan: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text('Jadilah yang pertama memberi ulasan!'),
                            ),
                          );
                        }

                        final reviews = snapshot.data!;
                        
                        // --- [PERBAIKAN] Ganti ListView.builder dengan SingleChildScrollView + Row ---
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start, // Align kartu ke atas
                            children: List.generate(min(reviews.length, 3), (index) {
                              return SizedBox(
                                width: screenWidth * 0.8,
                                child: Card(
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: ReviewCard(review: reviews[index]),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                        // --- BATAS PERBAIKAN ---
                      },
                    ),


                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _launchMapsUrl(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Visit', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // LAPISAN 3: APPBAR TRANSPARAN CUSTOM
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: const Icon(Icons.bookmark_border, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

