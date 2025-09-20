import 'package:flutter/material.dart';
import '../models/checkin_response.dart';
import '../services/checkin_service.dart';

class ReviewBottomSheet extends StatefulWidget {
  final CheckinSuccessResponse checkinResult;
  final Function(ReviewSuccessResponse) onReviewSuccess;

  const ReviewBottomSheet({
    super.key,
    required this.checkinResult,
    required this.onReviewSuccess,
});

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  final _commentController = TextEditingController();
  final _checkinService = CheckinService();
  
  double _rating = 3.0;
  bool _isLoading = false;

  Future<void> _submitReview() async {
    if (_commentController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar minimal 10 karakter.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final reviewResult = await _checkinService.submitReviewForCheckin(
        checkinId: widget.checkinResult.checkinId,
        rating: _rating.toInt(),
        comment: _commentController.text,
      );
      
      // Panggil callback jika berhasil
      widget.onReviewSuccess(reviewResult);
      if (mounted) Navigator.pop(context);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim review: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bagikan Pengalamanmu di', style: Theme.of(context).textTheme.titleMedium),
            Text(widget.checkinResult.restaurantName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Beri Rating: ${_rating.toInt()} Bintang', style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: _rating.toInt().toString(),
              onChanged: (value) => setState(() => _rating = value),
            ),
            TextField(
              controller: _commentController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Tuliskan sesuatu...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReview,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}