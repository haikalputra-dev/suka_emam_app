// lib/features/restaurants/widgets/location_filter_sheet.dart

import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/restaurants/views/all_places_page.dart'; // Import untuk akses PredefinedLocation

class LocationFilterSheet extends StatefulWidget {
  final List<PredefinedLocation> locations;
  final PredefinedLocation selectedLocation;

  const LocationFilterSheet({
    super.key,
    required this.locations,
    required this.selectedLocation,
  });

  @override
  State<LocationFilterSheet> createState() => _LocationFilterSheetState();
}

class _LocationFilterSheetState extends State<LocationFilterSheet> {
  late List<PredefinedLocation> _filteredLocations;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredLocations = widget.locations;
    _searchController.addListener(() {
      _filterLocations(_searchController.text);
    });
  }

  void _filterLocations(String query) {
    if (query.isEmpty) {
      _filteredLocations = widget.locations;
    } else {
      _filteredLocations = widget.locations
          .where((loc) => loc.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {}); // Update UI
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle & Judul
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Pilih Lokasi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari nama lokasi...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 16),

          // Daftar Lokasi
          Expanded(
            child: ListView.builder(
              itemCount: _filteredLocations.length,
              itemBuilder: (context, index) {
                final location = _filteredLocations[index];
                final isSelected = location.name == widget.selectedLocation.name;
                return ListTile(
                  title: Text(location.name),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                  onTap: () {
                    // Tutup bottom sheet dan kirim kembali lokasi yang dipilih
                    Navigator.pop(context, location);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}