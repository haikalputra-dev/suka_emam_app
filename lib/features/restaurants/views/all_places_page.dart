// lib/features/restaurants/views/all_places_page.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:suka_emam_app/features/restaurants/models/restaurant.dart';
import 'package:suka_emam_app/features/restaurants/services/mock_restaurant_service.dart';
import 'package:suka_emam_app/features/restaurants/widgets/location_filter_sheet.dart'; // <-- IMPORT WIDGET BARU
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
  final MockRestaurantService _restaurantService = MockRestaurantService();
  
  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  bool _isLoading = true;

  final List<PredefinedLocation> _locations = [
    PredefinedLocation(name: 'Alun-alun Kota', latitude: -6.921832, longitude: 106.934211),
    PredefinedLocation(name: 'Stasiun Sukabumi', latitude: -6.9175, longitude: 106.9275),
    PredefinedLocation(name: 'Citimall Sukabumi', latitude: -6.9381, longitude: 106.9255),
  ];
  late PredefinedLocation _selectedLocation;
  double _currentRadiusKm = 3.0;

  @override
  void initState() {
    super.initState();
    _selectedLocation = _locations.first;
    _fetchAndFilterRestaurants();
  }

  Future<void> _fetchAndFilterRestaurants() async {
    setState(() => _isLoading = true);
    if (_allRestaurants.isEmpty) {
      _allRestaurants = await _restaurantService.getAllRestaurants();
    }
    _applyFilter();
    setState(() => _isLoading = false);
  }

  void _applyFilter() {
    List<Restaurant> tempResult = [];
    for (var restaurant in _allRestaurants) {
      final distanceInMeters = Geolocator.distanceBetween(
        _selectedLocation.latitude, _selectedLocation.longitude,
        restaurant.latitude, restaurant.longitude,
      );
      if ((distanceInMeters / 1000) <= _currentRadiusKm) {
        tempResult.add(restaurant);
      }
    }
    setState(() => _filteredRestaurants = tempResult);
  }

  // --- FUNGSI BARU UNTUK MENAMPILKAN BOTTOM SHEET ---
  void _showLocationFilterSheet() async {
    final selected = await showModalBottomSheet<PredefinedLocation>(
      context: context,
      isScrollControlled: true, // Agar bisa set tinggi
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Tampilkan 80% dari tinggi layar
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: LocationFilterSheet(
            locations: _locations,
            selectedLocation: _selectedLocation,
          ),
        );
      },
    );

    // Jika user memilih lokasi baru, update state dan filter ulang
    if (selected != null) {
      setState(() {
        _selectedLocation = selected;
      });
      _applyFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Places')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- UI FILTER YANG SUDAH DIUPDATE ---
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: _showLocationFilterSheet, // Panggil bottom sheet
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
                          Text(_selectedLocation.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Radius: ${_currentRadiusKm.toStringAsFixed(0)} km'),
              Expanded(
                child: Slider(
                  value: _currentRadiusKm, min: 1, max: 10, divisions: 9,
                  label: '${_currentRadiusKm.toStringAsFixed(0)} km',
                  onChanged: (val) => setState(() => _currentRadiusKm = val),
                  onChangeEnd: (val) => _applyFilter(),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          // --- HASIL PENCARIAN (Kodenya sama seperti sebelumnya) ---
          Text('Ditemukan ${_filteredRestaurants.length} tempat', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredRestaurants.isEmpty
                  ? const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('Tidak ada restoran ditemukan dalam radius ini.')))
               :GridView.builder(
                  shrinkWrap: true, // Wajib di dalam ListView
                  physics: const NeverScrollableScrollPhysics(), // Wajib di dalam ListView
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 kolom
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8, // Rasio lebar:tinggi kartu
                  ),
                  itemCount: _filteredRestaurants.length,
                  itemBuilder: (context, index) {
                    return RestaurantGridCard(restaurant: _filteredRestaurants[index]);
                  },
                ),
        ],
      ),
    );
  }
}