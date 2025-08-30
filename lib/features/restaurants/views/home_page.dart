// lib/features/restaurants/views/home_page.dart

import 'package:firebase_auth/firebase_auth.dart'; // <-- Import Firebase Auth
import 'package:flutter/material.dart';
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
    // Siapkan nama user dengan placeholder "Guest" jika tidak ada
    final userName = user?.displayName?.isNotEmpty == true ? user!.displayName! : 'Guest';

    return FutureBuilder<List<Restaurant>>(
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- BAGIAN HEADER NAMA USER (PENGGANTI APPBAR) ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      // Kamu bisa ganti dengan user.photoURL jika ada
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      userName, // <-- Nama user dinamis di sini
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
                    const SizedBox(height: 24), // <-- TAMBAH JARAK KE BAWAH
                    const Text('Explore', style: TextStyle(fontSize: 40)), // <-- FONT DIPERBESAR
                    const Text(
                      'Dish in Sukabumi!',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFF9A825)), // <-- FONT DIPERBESAR
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
                      onPressed: () {},
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
          );
        }
        return const Center(child: Text('No recommended restaurants found.'));
      },
    );
  }
}