// lib/features/restaurants/widgets/restaurant_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/restaurants/models/restaurant.dart';
import 'package:suka_emam_app/features/restaurants/views/restaurant_detail_page.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantCard({super.key, required this.restaurant});

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
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar dengan ikon bookmark
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: CachedNetworkImage(
                    imageUrl: restaurant.mainImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[300]),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bookmark_border, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // --- INFO TEKS DI BAWAH GAMBAR ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.rating.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.shortAddress,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      overflow: TextOverflow.ellipsis
                    ),
                    // const Spacer(), // Mendorong avatar ke kanan
                    // // Tumpukan Avatar (Social Proof)
                    // SizedBox(
                    //   width: 60,
                    //   child: Stack(
                    //     children: [
                    //       // Avatar-avatar ini bisa diganti dengan data asli nanti
                    //       const CircleAvatar(radius: 12, backgroundColor: Colors.orange),
                    //       Positioned(
                    //         left: 15,
                    //         child: const CircleAvatar(radius: 12, backgroundColor: Colors.blue),
                    //       ),
                    //       Positioned(
                    //         left: 30,
                    //         child: CircleAvatar(
                    //           radius: 12,
                    //           backgroundColor: Colors.grey[300],
                    //           child: const Text('+50', style: TextStyle(fontSize: 8, color: Colors.black)),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      )
    );
  }
}