import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:suka_emam_app/features/scan/services/checkin_service.dart';
import 'package:suka_emam_app/features/scan/views/review_success_page.dart';

class ReviewPage extends StatefulWidget {
  final String checkinId;
  final String restaurantName;

  const ReviewPage({
    super.key,
    required this.checkinId,
    required this.restaurantName,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _rating = 0;
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final CheckinService _checkinService = CheckinService();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile; // State untuk menyimpan file gambar yang dipilih

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  void _submitReview() async {
    if (!_formKey.currentState!.validate() || _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon berikan rating bintang terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _checkinService.submitReviewForCheckin(
        checkinId: widget.checkinId,
        rating: _rating,
        comment: _commentController.text,
        photo: _imageFile, // Kirim file gambar ke service
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ReviewSuccessPage()),
        );
      }
    } catch (e) {
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
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beri Ulasan untuk ${widget.restaurantName}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text('Bagaimana pengalamanmu? Beri rating:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Tulis Komentar',
                border: OutlineInputBorder(),
              ),
              minLines: 4,
              maxLines: 6,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Komentar tidak boleh kosong';
                }
                if (value.length < 10) {
                  return 'Komentar minimal 10 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // --- UI BARU UNTUK UPLOAD FOTO ---
            const Text('Tambahkan Foto (Opsional):', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            if (_imageFile == null)
              OutlinedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Pilih dari Galeri'),
                onPressed: _pickImage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              )
            else
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.file(File(_imageFile!.path)),
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                    onPressed: () => setState(() => _imageFile = null),
                  ),
                ],
              ),
            // --- BATAS UI BARU ---

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitReview,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                  : const Text('Kirim Ulasan'),
            )
          ],
        ),
      ),
    );
  }
}

