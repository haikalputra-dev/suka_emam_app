// lib/features/restaurants/views/all_places_page.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:suka_emam_app/core/location_service.dart';
import 'package:suka_emam_app/features/restaurants/models/restaurant.dart'
    as restaurant_models;
import 'package:suka_emam_app/features/restaurants/services/restaurant_service.dart';
import 'package:suka_emam_app/features/restaurants/widgets/location_filter_sheet.dart';
import 'package:suka_emam_app/features/restaurants/widgets/restaurant_grid_card.dart';

class PredefinedLocation {
  final String name;
  final double latitude;
  final double longitude;
  PredefinedLocation({required this.name, required this.latitude, required this.longitude});
}

class AllPlacesPage extends StatefulWidget {
  const AllPlacesPage({super.key});

  @override
  State<AllPlacesPage> createState() => _AllPlacesPageState();
}

class _AllPlacesPageState extends State<AllPlacesPage> {
  final RestaurantService _restaurantService = RestaurantService();
  final LocationService _locationService = LocationService();

  Future<List<restaurant_models.Restaurant>>? _restaurantsFuture;
  String _currentLocationName = 'Mencari lokasi...';
  Position? _cachedGpsPosition; // <-- State untuk menyimpan posisi GPS

  final List<PredefinedLocation> _predefinedLocations = [
    PredefinedLocation(name: 'Alun-alun Kota', latitude: -6.921832, longitude: 106.934211),
    PredefinedLocation(name: 'Stasiun Sukabumi', latitude: -6.9175, longitude: 106.9275),
    PredefinedLocation(name: 'Citimall Sukabumi', latitude: -6.9381, longitude: 106.9255),
  ];

  @override
  void initState() {
    super.initState();
    _fetchNearbyRestaurants();
  }

  // Metode utama untuk mengambil restoran terdekat berdasarkan GPS
  Future<void> _fetchNearbyRestaurants() async {
    setState(() {
      _currentLocationName = 'Mencari lokasimu...';
      _restaurantsFuture = null;
    });

    try {
      Position position;
      // -- LOGIKA CACHING DIMULAI DI SINI --
      if (_cachedGpsPosition != null) {
        // Jika cache sudah ada, langsung gunakan
        position = _cachedGpsPosition!;
      } else {
        // Jika cache kosong, panggil service untuk mendapatkan lokasi baru
        position = await _locationService.getCurrentPosition();
        // Simpan hasilnya ke cache untuk penggunaan berikutnya
        _cachedGpsPosition = position;
      }
      // -- LOGIKA CACHING SELESAI --
      
      setState(() {
        _currentLocationName = 'Lokasi Saat Ini';
        _restaurantsFuture = _restaurantService.getRestaurants(userPosition: position);
      });
    } catch (e) {
      setState(() {
        _currentLocationName = 'Gagal Mendapatkan Lokasi';
        _restaurantsFuture = _restaurantService.getRestaurants();
      });
    }
  }

  void _showLocationFilterSheet() async {
    final selected = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: LocationFilterSheet(
            locations: [PredefinedLocation(name: 'Lokasi Saat Ini', latitude: 0, longitude: 0), ..._predefinedLocations],
            selectedLocation: PredefinedLocation(name: _currentLocationName, latitude: 0, longitude: 0),
          ),
        );
      },
    );

    if (selected != null) {
      if (selected.name == 'Lokasi Saat Ini') {
        _fetchNearbyRestaurants();
      } else if (selected is PredefinedLocation) {
        setState(() {
          _currentLocationName = selected.name;
          final position = Position(
              latitude: selected.latitude, longitude: selected.longitude,
              timestamp: DateTime.now(), accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
          _restaurantsFuture = _restaurantService.getRestaurants(userPosition: position);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Places')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: _showLocationFilterSheet,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Lokasi Pencarian', style: TextStyle(color: Colors.grey)),
                            Text(_currentLocationName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_restaurantsFuture == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_currentLocationName),
          ],
        ),
      );
    }
    
    return FutureBuilder<List<restaurant_models.Restaurant>>(
      future: _restaurantsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Gagal memuat restoran: ${snapshot.error}'),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada restoran ditemukan.'));
        }
        
        final restaurants = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            return RestaurantGridCard(restaurant: restaurants[index]);
          },
        );
      },
    );
  }
}