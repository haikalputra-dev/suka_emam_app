// lib/features/restaurants/views/home_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/restaurants/views/all_places_page.dart';
import 'package:suka_emam_app/features/leaderboard/views/leaderboard_page.dart';
import '../models/restaurant.dart' as restaurant_models;
import '../services/restaurant_service.dart';
import '../widgets/restaurant_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Ganti Mock service dengan service asli
  final RestaurantService _restaurantService = RestaurantService();
  // Gunakan tipe data dengan prefix
  late Future<List<restaurant_models.Restaurant>> _recommendedRestaurantsFuture;

  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    // Panggil service asli dengan parameter 'onlyRecommended: true'
    _recommendedRestaurantsFuture = _restaurantService.getRestaurants(onlyRecommended: true);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName?.isNotEmpty == true ? user!.displayName! : 'Guest';
    final photoURL = user?.photoURL;

    return SafeArea(
      // Gunakan tipe data dengan prefix di FutureBuilder
      child: FutureBuilder<List<restaurant_models.Restaurant>>(
        future: _recommendedRestaurantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final restaurants = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BAGIAN HEADER (Tidak ada perubahan) ---
Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
                          child: photoURL == null
                              ? const Icon(Icons.person, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        // Bungkus dengan Expanded agar nama user mengambil sisa ruang
                        // dan mendorong ikon ke paling kanan.
                        Expanded(
                          child: Text(
                            userName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        // [BARU] Tombol ikon untuk leaderboard
                        IconButton(
                          icon: const Icon(Icons.leaderboard_outlined, color: Colors.amber),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LeaderboardPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // --- BAGIAN JUDUL (Tidak ada perubahan) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 24),
                        Text('Explore', style: TextStyle(fontSize: 40)),
                        Text(
                          'Dish in Sukabumi!',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFF9A825)),
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recommended for you',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AllPlacesPage()),
                            );
                          },
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // PageView (Tidak ada perubahan)
                  SizedBox(
                    height: screenHeight * 0.45, // Mungkin perlu disesuaikan
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: restaurants.length,
                      itemBuilder: (context, index) {
                        // Di sini tidak perlu parameter 'onlyRecommended'
                        return RestaurantCard(restaurant: restaurants[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          // Tampilan jika tidak ada data atau data kosong
          return const Center(child: Text('Tidak ada restoran rekomendasi yang ditemukan.'));
        },
      ),
    );
  }
}