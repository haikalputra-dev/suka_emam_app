// lib/features/restaurants/views/home_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/restaurants/views/all_places_page.dart';
import '../models/restaurant.dart';
import '../services/mock_restaurant_service.dart';
import '../widgets/restaurant_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MockRestaurantService _restaurantService = MockRestaurantService();
  late Future<List<Restaurant>> _recommendedRestaurantsFuture;

  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    _recommendedRestaurantsFuture = _restaurantService.getRecommendedRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Ambil data user yang sedang login
    final user = FirebaseAuth.instance.currentUser;
    // Siapkan nama dan URL foto user dengan placeholder
    final userName = user?.displayName?.isNotEmpty == true ? user!.displayName! : 'Guest';
    final photoURL = user?.photoURL; // <-- PERUBAHAN DI SINI: Ambil URL foto

    // <-- PERUBAHAN DI SINI: Tambahkan SafeArea
    return SafeArea( 
      child: FutureBuilder<List<Restaurant>>(
        future: _recommendedRestaurantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final restaurants = snapshot.data!;
            return SingleChildScrollView( // <-- PERUBAHAN DI SINI: Agar bisa di-scroll jika kontennya panjang
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BAGIAN HEADER NAMA USER (PENGGANTI APPBAR) ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        // <-- PERUBAHAN DI SINI: Logika untuk menampilkan foto profil
                        CircleAvatar(
                          radius: 20, // Sedikit diperbesar agar terlihat bagus
                          backgroundColor: Colors.grey[200],
                          // Jika photoURL ada, tampilkan sebagai background. Jika tidak, tampilkan null.
                          backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
                          // Jika photoURL tidak ada (backgroundImage null), tampilkan ikon person.
                          child: photoURL == null
                              ? const Icon(Icons.person, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          userName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  // Bagian Judul
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        const Text('Explore', style: TextStyle(fontSize: 40)),
                        const Text(
                          'Dish in Sukabumi!',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFF9A825)),
                        ),
                        const SizedBox(height: 24),
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

                  // PageView
                  SizedBox(
                    height: screenHeight * 0.65,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: restaurants.length,
                      itemBuilder: (context, index) {
                        return RestaurantCard(restaurant: restaurants[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No recommended restaurants found.'));
        },
      ),
    );
  }
}