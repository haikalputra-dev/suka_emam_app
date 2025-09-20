import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:suka_emam_app/core/location_service.dart';
import 'package:suka_emam_app/features/scan/models/checkin_response.dart';
import 'package:suka_emam_app/features/scan/services/checkin_service.dart';
import 'package:suka_emam_app/features/scan/views/review_bottom_sheet.dart';
import 'package:suka_emam_app/features/scan/views/success_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});
  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final CheckinService _checkinService = CheckinService();
  final LocationService _locationService = LocationService();

  bool _isLoading = false;

  // Fungsi utama yang dipanggil saat QR terdeteksi
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isLoading) return; // Mencegah scan ganda saat proses berjalan

    final String? qrCode = capture.barcodes.first.rawValue;
    if (qrCode == null) return;

    setState(() => _isLoading = true);
    _scannerController.stop(); // Hentikan kamera sementara

    try {
      // 1. Ambil lokasi pengguna
      final position = await _locationService.getCurrentPosition();

      // 2. Kirim data ke API check-in via service baru
      final checkinResult = await _checkinService.performCheckin(
        qrCode: qrCode,
        position: position,
      );

      // 3. Tampilkan halaman sukses check-in & tunggu hingga ditutup
      await _showCheckinSuccess(checkinResult);

      // 4. Setelah halaman sukses ditutup, tampilkan pop-up review
      await _showReviewBottomSheet(checkinResult);

    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scannerController.start(); // Nyalakan lagi kamera untuk scan berikutnya
      }
    }
  }

  // Helper untuk menampilkan halaman sukses check-in
  Future<void> _showCheckinSuccess(CheckinSuccessResponse result) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SuccessPage(
        title: 'Scan QR Sukses!',
        message: '+${result.pointsEarned} Poin',
        imageAsset: 'assets/badges/scan_success.png', 
        onClose: () => Navigator.of(context).pop(),
      ),
    ));
  }
  
  // Helper untuk menampilkan pop-up review
  Future<void> _showReviewBottomSheet(CheckinSuccessResponse checkinResult) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ReviewBottomSheet(
        checkinResult: checkinResult,
        onReviewSuccess: (reviewResult) {
          // Jika review berhasil, tampilkan halaman sukses review
          _showReviewSuccess(reviewResult);
        },
      ),
    );
  }

  // Helper untuk menampilkan halaman sukses setelah review
  void _showReviewSuccess(ReviewSuccessResponse reviewResult) {
     // Gunakan pushReplacement agar tidak bisa kembali ke bottom sheet
     Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => SuccessPage(
        title: 'Ulasan Sukses!',
        message: 'Kamu mendapatkan +${reviewResult.pointsEarned} Poin',
        imageAsset: 'assets/badges/review_success.png', // Sesuaikan path gambar Anda
        onClose: () {
          // Kembali ke halaman awal scan
          Navigator.of(context).pop();
        },
      ),
    ));
  }

  // Helper untuk menampilkan error dalam bentuk Snackbar
  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text('Scan QR Code'),
      actions: [
        IconButton(
          tooltip: 'Flash',
          onPressed: () => _scannerController.toggleTorch(),
          icon: ValueListenableBuilder(
            // Dengarkan seluruh controller
            valueListenable: _scannerController,
            builder: (context, state, child) {
              // Di dalam builder, kita bisa akses state-nya
              return Icon(state.torchState == TorchState.on 
                  ? Icons.flash_on 
                  : Icons.flash_off);
            },
          ),
        ),
        IconButton(
          tooltip: 'Switch Camera',
          onPressed: () => _scannerController.switchCamera(),
          icon: ValueListenableBuilder(
            // Dengarkan seluruh controller
            valueListenable: _scannerController,
            builder: (context, state, child) {
              // Di dalam builder, kita bisa akses state-nya
              return Icon(state.cameraDirection == CameraFacing.front
                  ? Icons.camera_front
                  : Icons.camera_rear);
            },
          ),
        ),
      ],
    ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          // UI Overlay (kotak scan, banner, dll)
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 4),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Memproses...', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}