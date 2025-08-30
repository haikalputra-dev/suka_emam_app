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

  // Controller terbaru: ValueNotifier<MobileScannerState>
  final MobileScannerController _controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates, // cegah spam callback
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

    // ambil lokasi akurat; timeLimit biar ga ngegantung
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
      // stop camera sementara supaya gak detect berulang-ulang
      await _controller.stop();

      // ambil lokasi sekarang
      final pos = await _getPosition();

      // kirim ke server — penting: lat/lng/accuracy disertakan
      final res = await DioClient.i.post(
        '/checkin',
        data: {
          'qr': qr,
          'lat': pos.latitude,
          'lng': pos.longitude,
          'accuracy': pos.accuracy, // meter
        },
      );

      final data = res.data as Map;
      final pts = data['points_earned'] ?? data['points'] ?? 0;
      final total = data['total_points'];
      final dist = data['distance_m'];
      final radius = data['radius_m'];

      if (!mounted) return;
      setState(() => _banner = 'Check-in sukses! +$pts pts (∑ $total) • ~${dist}m/≤${radius}m');

      // kasih dialog kecil, lalu close page
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
      String msg = 'Gagal check-in';
      final r = e.response;
      if (r != null) {
        final body = r.data;
        if (body is Map && body['errors'] is Map) {
          final errs = body['errors'] as Map;
          // prioritas error dari server
          for (final key in ['limit', 'location', 'qr', 'auth']) {
            if (errs[key] is List && (errs[key] as List).isNotEmpty) {
              msg = (errs[key] as List).first.toString();
              break;
            }
          }
          // fallback: ambil error pertama yang ada
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
      // nyalain kamera lagi supaya user bisa coba ulang
      await _controller.start();
    } catch (e) {
      if (!mounted) return;
      setState(() => _banner = 'Gagal: $e');
      await _controller.start();
    } finally {
      // biar banner kebaca sebentar
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _busy = false);
    }
  }

  // tombol simulasi check-in (buat ngetes tanpa kamera)
  void _simulate() => _handleScan('SE-V1|2|1755245653|nonce|sig');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR'),
        actions: [
          // Flash toggle
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
          // Switch camera
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
          // Simulate (opsional)
          IconButton(
            tooltip: 'Simulate',
            onPressed: _simulate,
            icon: const Icon(Icons.play_arrow),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Preview kamera + deteksi
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final code = capture.barcodes.firstOrNull?.rawValue;
              if (code != null && !_busy) {
                // tunjukin deteksi sekali
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Detected: $code'), duration: const Duration(milliseconds: 700)),
                );
                _handleScan(code);
              }
            },
          ),

          // Overlay frame sederhana
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

          // Banner status bawah
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
