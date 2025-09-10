// lib/features/restaurants/views/all_places_page.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:suka_emam_app/features/restaurants/models/restaurant.dart';
import 'package:suka_emam_app/features/restaurants/services/restaurant_service.dart'; // <-- UBAH: Hanya impor service asli
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
  // <-- UBAH: Gunakan RestaurantService yang asli
  final RestaurantService _restaurantService = RestaurantService();
  
  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  bool _isLoading = true;
  String _errorMessage = ''; // Untuk menyimpan pesan error jika ada

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

  // <-- UBAH: Tambahkan blok try-catch untuk penanganan eror
  Future<void> _fetchAndFilterRestaurants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_allRestaurants.isEmpty) {
        // Panggil method dari service asli (pastikan nama methodnya `getRestaurants`)
        _allRestaurants = await _restaurantService.getRestaurants();
      }
      _applyFilter();
    } catch (e) {
      // Jika terjadi eror saat fetch data
      setState(() {
        _errorMessage = 'Gagal memuat data. Periksa koneksi internet Anda.';
      });
      print('Error fetching restaurants: $e');
    } finally {
      // Pastikan loading state selalu false di akhir
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilter() {
    List<Restaurant> tempResult = [];
    for (var restaurant in _allRestaurants) {
      // Pastikan model Restaurant Anda memiliki properti latitude dan longitude
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

  void _showLocationFilterSheet() async {
    final selected = await showModalBottomSheet<PredefinedLocation>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: LocationFilterSheet(
            locations: _locations,
            selectedLocation: _selectedLocation,
          ),
        );
      },
    );

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
          Card(
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
          Text('Ditemukan ${_filteredRestaurants.length} tempat', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildRestaurantGrid(), // Panggil method untuk build konten
        ],
      ),
    );
  }

  // Widget helper untuk merapikan bagian body
  Widget _buildRestaurantGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage.isNotEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(32.0), child: Text(_errorMessage)));
    }
    if (_filteredRestaurants.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('Tidak ada restoran ditemukan dalam radius ini.')));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredRestaurants.length,
      itemBuilder: (context, index) {
        return RestaurantGridCard(restaurant: _filteredRestaurants[index]);
      },
    );
  }
}