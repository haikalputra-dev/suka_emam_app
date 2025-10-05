import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:suka_emam_app/core/location_service.dart';
import 'package:suka_emam_app/features/scan/models/checkin_response.dart';
import 'package:suka_emam_app/features/scan/services/checkin_service.dart';
import 'package:suka_emam_app/features/scan/views/processing_page.dart';
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

  bool _isProcessing = false; // Mencegah scan ganda saat proses berjalan

  // Fungsi yang dipanggil saat QR terdeteksi
  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final String? qrCode = capture.barcodes.first.rawValue;
    if (qrCode == null || qrCode.isEmpty) return;
    
    setState(() => _isProcessing = true);
    _scannerController.stop(); // Hentikan kamera

    // 1. Langsung navigasi ke halaman proses
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProcessingPage()),
    ).then((_) {
      // Ini akan dijalankan saat kita kembali dari halaman proses (jika terjadi error)
      if (mounted) {
        setState(() => _isProcessing = false);
        _scannerController.start(); // Nyalakan lagi kamera
      }
    });

    // 2. Jalankan logika check-in di latar belakang
    _submitCheckin(qrCode);
  }

  // Fungsi untuk mengirim data check-in ke server
  Future<void> _submitCheckin(String qrCode) async {
    try {
      // Ambil lokasi pengguna
      final Position position = await _locationService.getCurrentPosition();

      // Kirim data ke API check-in
      final CheckinSuccessResponse checkinResult = await _checkinService.performCheckin(
        qrCode: qrCode,
        position: position,
      );

      if (mounted) {
        // 3. Ganti halaman proses dengan halaman sukses
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CheckinSuccessPage(result: checkinResult)),
        );
      }
    } catch (e) {
      if (mounted) {
        // Jika gagal, kembali dari halaman proses
        Navigator.pop(context); 
        _showErrorSnackbar(e.toString());
      }
    }
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
              valueListenable: _scannerController,
              builder: (context, state, child) {
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
              valueListenable: _scannerController,
              builder: (context, state, child) {
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
          // UI Overlay (kotak scan)
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 4),
            ),
          ),
        ],
      ),
    );
  }
}
