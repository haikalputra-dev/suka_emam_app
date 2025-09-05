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
        clipBehavior: Clip.antiAlias, // Agar ClipRRect dihormati oleh Card
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            Expanded(
              child: CachedNetworkImage(
                imageUrl: restaurant.mainImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => const Icon(Icons.broken_image),
              ),
            ),
            // Teks Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.shortAddress,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}