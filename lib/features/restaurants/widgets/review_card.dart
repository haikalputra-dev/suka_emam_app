import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/restaurants/models/review.dart';
import 'package:suka_emam_app/features/restaurants/views/photo_viewer_page.dart'; // <-- Import halaman baru

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    // --- [PERBAIKAN] Fungsi timeAgo dibuat lebih aman ---
    String timeAgo(String dateString) {
      try {
        // Coba parse tanggal dengan format standar ISO 8601
        final date = DateTime.parse(dateString);
        final difference = DateTime.now().difference(date);
        
        if (difference.inDays > 365) {
          return '${(difference.inDays / 365).floor()} tahun lalu';
        } else if (difference.inDays > 30) {
          return '${(difference.inDays / 30).floor()} bulan lalu';
        } else if (difference.inDays > 7) {
          return '${(difference.inDays / 7).floor()} minggu lalu';
        } else if (difference.inDays > 0) {
          return '${difference.inDays} hari lalu';
        } else if (difference.inHours > 0) {
          return '${difference.inHours} jam lalu';
        } else if (difference.inMinutes > 0) {
          return '${difference.inMinutes} menit lalu';
        } else {
          return 'Baru saja';
        }
      } catch (e) {
        return dateString;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: review.user.avatarUrl != null ? NetworkImage(review.user.avatarUrl!) : null,
            child: review.user.avatarUrl == null ? const Icon(Icons.person, size: 20) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.user.name ?? 'Pengguna Anonim', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  timeAgo(review.createdAt), // Panggil fungsi yang sudah diperbaiki
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(review.comment),
                
                if (review.photoUrlThumbnail != null && review.photoUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhotoViewerPage(
                              imageUrl: review.photoUrl!,
                              heroTag: review.id,
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: review.id,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: review.photoUrlThumbnail!,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(height: 80, width: 80, color: Colors.grey[200]),
                            errorWidget: (context, url, error) => Container(
                              height: 80, width: 80, color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

