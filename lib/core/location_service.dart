// lib/core/location_service.dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Mendapatkan posisi pengguna saat ini.
  /// Akan menangani semua logika izin secara otomatis.
  /// Melempar Exception jika izin ditolak permanen atau lokasi tidak tersedia.
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Cek apakah layanan lokasi di perangkat aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi nonaktif. Mohon aktifkan di pengaturan.');
    }

    // 2. Cek status izin saat ini
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Jika belum pernah ditanya, minta izin
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }

    // 3. Jika izin ditolak permanen, beri pesan error
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen. Mohon aktifkan di pengaturan aplikasi.');
    }

    // 4. Jika semua izin sudah oke, dapatkan lokasi
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium // Akurasi medium cukup untuk restoran
    );
  }
}