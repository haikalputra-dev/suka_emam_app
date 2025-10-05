import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PhotoViewerPage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const PhotoViewerPage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Membuat tombol back menjadi putih
      ),
      body: Center(
        // Hero digunakan untuk animasi zoom-in dari thumbnail
        child: Hero(
          tag: heroTag,
          // InteractiveViewer memungkinkan pengguna untuk zoom-in dan zoom-out
          child: InteractiveViewer(
            panEnabled: false,
            minScale: 1.0,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain, // Menampilkan seluruh gambar tanpa memotong
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
