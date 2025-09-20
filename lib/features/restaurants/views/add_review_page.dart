// lib/features/restaurants/views/add_review_page.dart

import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/restaurants/services/restaurant_service.dart';

class AddReviewPage extends StatefulWidget {
  final int restaurantId;

  const AddReviewPage({super.key, required this.restaurantId});

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final _commentController = TextEditingController();
  final _restaurantService = RestaurantService();
  
  double _rating = 3.0; // Nilai rating awal
  bool _isLoading = false;

  Future<void> _submitReview() async {
    // Validasi sederhana
    if (_commentController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar minimal 10 karakter.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _restaurantService.submitReview(
        restaurantId: widget.restaurantId,
        rating: _rating.toInt(),
        comment: _commentController.text,
      );

      // Jika berhasil
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review berhasil dikirim! Terima kasih.'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Kirim 'true' untuk menandakan ada data baru
      }
    } catch (e) {
      // Jika gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim review: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tulis Review'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rating Anda: ${_rating.toInt()} Bintang', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Slider(
              value: _rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: _rating.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _commentController,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Komentar Anda',
                hintText: 'Bagaimana pengalaman Anda di sini?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Kirim Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}