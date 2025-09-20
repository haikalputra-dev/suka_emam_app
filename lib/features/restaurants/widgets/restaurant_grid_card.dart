// lib/features/restaurants/widgets/restaurant_grid_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/restaurants/models/restaurant.dart';
import 'package:suka_emam_app/features/restaurants/views/restaurant_detail_page.dart';

class RestaurantGridCard extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantGridCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailPage(restaurant: restaurant),
          ),
        );
      },
      child: Card(
      clipBehavior: Clip.antiAlias, // Penting agar gambar tidak keluar dari corner radius Card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Gunakan Stack untuk menumpuk widget
          Stack(
            children: [
              // Lapisan 1: Gambar Restoran (paling bawah)
              AspectRatio(
                aspectRatio: 16 / 10, // Rasio gambar agar seragam
                child: CachedNetworkImage(
                  imageUrl: restaurant.mainImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                ),
              ),

              // Lapisan 2: Badge Jarak (di atas gambar)
              // Hanya tampilkan jika data jarak ada
              if (restaurant.distanceKm != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${restaurant.distanceKm?.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // 2. Bagian teks di bawah gambar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.shortAddress, // Gunakan shortAddress
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}