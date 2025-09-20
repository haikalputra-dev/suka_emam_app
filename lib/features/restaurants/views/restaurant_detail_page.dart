// lib/features/restaurants/views/restaurant_detail_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/restaurants/models/restaurant.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantDetailPage extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailPage({super.key, required this.restaurant});

    Future<void> _launchMapsUrl(BuildContext context) async {
    final lat = restaurant.latitude;
    final lng = restaurant.longitude;
    // URL ini akan membuka aplikasi Google Maps jika terinstall, jika tidak akan membuka di browser
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      // Tampilkan pesan error jika tidak bisa membuka link
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

  print('--- RENDERING DETAIL PAGE ---');
  print('URL DITERIMA WIDGET: "${restaurant.mainImageUrl}"');
  print('-----------------------------');

    return Scaffold(
      // Kita tidak pakai AppBar di sini agar bisa membuat AppBar custom di atas gambar
      body: Stack(
        children: [
          // LAPISAN 1: GAMBAR BACKGROUND
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CachedNetworkImage(
              imageUrl: restaurant.mainImageUrl,
              fit: BoxFit.cover,
              height: screenHeight * 0.45, // Gambar mengisi 45% atas layar
              width: screenWidth,
            ),
          ),

          // LAPISAN 2: KONTEN PUTIH YANG BISA DI-SCROLL
          Positioned.fill(
            top: screenHeight * 0.4, // Kartu putih mulai dari 40% tinggi layar (agar menumpuk)
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
                    // Judul Restoran
                    Text(
                      restaurant.name,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    
                    // Info Lokasi & Rating
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(restaurant.shortAddress, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 16),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text('${restaurant.rating} (${restaurant.reviewCount})', style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Info Harga
                     Row(
                      children: [
                        const Icon(Icons.price_change_outlined, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(restaurant.priceInfo, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),

                    const Divider(height: 32),
                    
                    // Galeri
                    const Text('Gallery', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: restaurant.galleryImageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                imageUrl: restaurant.galleryImageUrls[index],
                                width: 80, height: 80, fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const Divider(height: 32),

                    // Tentang Restoran
                    const Text('About Restaurant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                      restaurant.description,
                      style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 16),
                    ),

                    const SizedBox(height: 32),

                    // Tombol Visit
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
            top: MediaQuery.of(context).padding.top, // Agar tidak tertutup status bar
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Back
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Tombol Bookmark
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