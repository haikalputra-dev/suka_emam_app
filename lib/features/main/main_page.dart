// lib/features/main/main_page.dart

import 'package:flutter/material.dart';
import 'package:suka_emam_app/features/restaurants/views/home_page.dart';
import 'package:suka_emam_app/features/scan/scan_page.dart';
import 'package:suka_emam_app/features/profile/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    Placeholder(child: Center(child: Text('Scan Page'))), // Ini akan jadi halaman Scan
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    // Kita skip index 1 karena itu untuk Floating Action Button
    if (index == 1) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pindahkan body ke sini agar AppBar (jika ada) dan body berganti bersamaan
      body: _pages[_selectedIndex],

      // Tombol Scan QR di tengah
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // --- GANTI BAGIAN INI ---
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScanPage()),
          );
          // --- SAMPAI SINI ---
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Navigasi Bawah yang sudah dimodifikasi
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Membuat coakan untuk tombol
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home, color: _selectedIndex == 0 ? Theme.of(context).colorScheme.primary : Colors.grey),
              onPressed: () => _onItemTapped(0),
            ),
            const SizedBox(width: 40), // Ruang kosong untuk coakan
            IconButton(
              icon: Icon(Icons.person, color: _selectedIndex == 2 ? Theme.of(context).colorScheme.primary : Colors.grey),
              // Pindah ke index 2, karena index 1 adalah placeholder untuk scan
              onPressed: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
    );
  }
}