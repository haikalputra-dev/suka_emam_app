import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/scan/models/checkin_response.dart';
import 'package:suka_emam_app/features/scan/views/review_page.dart';

class CheckinSuccessPage extends StatelessWidget {
  final CheckinSuccessResponse result;

  const CheckinSuccessPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Image.asset('assets/badges/scan_success.png', height: 180),
              const SizedBox(height: 32),
              Text(
                'Check-in Berhasil!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Selamat! Kamu mendapatkan +${result.pointsEarned} Poin',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.grey[800]),
              ),
              if (result.levelUp) ...[
                const SizedBox(height: 8),
                Text(
                  '🎉 Level Up! Kamu sekarang Level ${result.currentLevel} 🎉',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Bantu komunitas dengan memberikan ulasan untuk ${result.restaurantName}.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Navigasi ke halaman review yang baru
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewPage(
                        checkinId: result.checkinId,
                        restaurantName: result.restaurantName,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Beri Ulasan'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // Kembali ke halaman paling awal (home)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Tutup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

