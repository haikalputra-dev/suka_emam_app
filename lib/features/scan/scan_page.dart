import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/dio_client.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});
  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _busy = false;
  String? _banner;

  final MobileScannerController _controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    returnImage: false,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Position> _getPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location service off. Aktifkan GPS.';
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      throw 'Izin lokasi ditolak.';
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 12),
    );
  }

  Future<void> _handleScan(String qr) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _banner = 'Memproses check-in...';
    });

    try {
      await _controller.stop();
      final pos = await _getPosition();

      // --- MENGGUNAKAN METHOD DIO CLIENT YANG SUDAH RAPI ---
      final res = await DioClient.checkin(
        qr: qr,
        lat: pos.latitude,
        lng: pos.longitude,
        accuracy: pos.accuracy,
      );
      // ----------------------------------------------------

      final data = res.data as Map;
      final pts = data['points_earned'] ?? data['points'] ?? 0;
      final total = data['total_points'];
      final dist = data['distance_m'];
      final radius = data['radius_m'];

      if (!mounted) return;
      setState(() => _banner = 'Check-in sukses! +$pts pts (∑ $total) • ~${dist}m/≤${radius}m');

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Check-in Berhasil 🎉'),
          content: Text('Poin +$pts\nTotal: $total\nJarak: ~${dist}m (batas ${radius}m)'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(); // balik ke halaman sebelumnya
    } on DioException catch (e) {
      print('DIO ERROR STATUS CODE: ${e.response?.statusCode}');
      print('DIO RESPONSE BODY: ${e.response?.data}');
      String msg = 'Gagal check-in';
      final r = e.response;
      if (r != null) {
        final body = r.data;
        if (body is Map && body['errors'] is Map) {
          final errs = body['errors'] as Map;
          for (final key in ['limit', 'location', 'qr', 'auth']) {
            if (errs[key] is List && (errs[key] as List).isNotEmpty) {
              msg = (errs[key] as List).first.toString();
              break;
            }
          }
          if (msg == 'Gagal check-in' && errs.isNotEmpty) {
            final first = (errs.values.first as List).first;
            msg = first.toString();
          }
        } else if (body is Map && body['message'] is String) {
          msg = body['message'] as String;
        }
      } else {
        msg = e.message ?? msg;
      }

      if (!mounted) return;
      setState(() => _banner = 'Gagal: $msg');
      await _controller.start();
    } catch (e) {
      if (!mounted) return;
      setState(() => _banner = 'Gagal: $e');
      await _controller.start();
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _busy = false);
    }
  }

  // Fungsi _simulate() sudah dihapus

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR'),
        actions: [
          IconButton(
            tooltip: 'Flash',
            onPressed: () => _controller.toggleTorch(),
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, _) {
                final s = state as MobileScannerState;
                return Icon(s.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off);
              },
            ),
          ),
          IconButton(
            tooltip: 'Switch Camera',
            onPressed: () => _controller.switchCamera(),
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, _) {
                final s = state as MobileScannerState;
                return Icon(s.cameraDirection == CameraFacing.front ? Icons.camera_front : Icons.camera_rear);
              },
            ),
          ),
          // Tombol Simulate sudah dihapus
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final code = capture.barcodes.firstOrNull?.rawValue;
              if (code != null && !_busy) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Detected: $code'), duration: const Duration(milliseconds: 700)),
                );
                _handleScan(code);
              }
            },
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
          ),
          if (_banner != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.80),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_banner!, style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}