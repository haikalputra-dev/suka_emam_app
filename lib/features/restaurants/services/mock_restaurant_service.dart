// lib/features/restaurants/services/mock_restaurant_service.dart

import '../models/restaurant.dart';

class MockRestaurantService {
  // Data dummy kita, sesuai dengan desain dan model
  final List<Restaurant> _dummyRestaurants = [
    Restaurant(
      id: 1,
      name: 'Mie Goreng Mang Roy',
      categories: ['Mie', 'Jajanan', 'Kaki Lima'],
      shortAddress: 'Alun Alun Sukabumi',
      fullAddress: 'Jl. Alun-Alun Utara No. 1, Sukabumi',
      description: 'Mie goreng legendaris dengan bumbu khas yang bikin nagih. Porsi melimpah, harga bersahabat.',
      rating: 4.5,
      reviewCount: 152,
      priceInfo: 'Mulai dari Rp 15k/porsi',
      mainImageUrl: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?q=80&w=300',
      galleryImageUrls: ['https://images.unsplash.com/photo-1585032226651-759b368d7246?q=80&w=300'],
      isRecommended: true,
      latitude: -6.925501,
      longitude: 106.927423,
    ),
    Restaurant(
      id: 2,
      name: 'Warteg Bahari',
      categories: ['Nasi', 'Ayam', 'Minuman'],
      shortAddress: 'Benteng, Sukabumi',
      fullAddress: 'Jl. Benteng No. 45, Warudoyong, Sukabumi',
      description: 'Murah banget bang, ceban paket kenyang. Pilihan lauknya banyak dan rasanya otentik.',
      rating: 4.4,
      reviewCount: 105,
      priceInfo: 'Mulai dari Rp 10k/porsi',
      mainImageUrl: 'https://images.unsplash.com/photo-1476055439777-977cdf3a5699?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      galleryImageUrls: [
        'https://images.unsplash.com/photo-1568205934931-a2260f8197b3?q=80&w=300',
        'https://images.unsplash.com/photo-1625944228741-cf3b93a52194?q=80&w=300',
      ],
      isRecommended: true,
      latitude: -6.921832,
      longitude: 106.934211,

    ),
    Restaurant(
      id: 3,
      name: 'Soto Ayam Asli Lamongan',
      categories: ['Soto', 'Ayam', 'Berkuah'],
      shortAddress: 'Ciaul, Sukabumi',
      fullAddress: 'Jl. R.A. Kosasih No. 101, Ciaul, Sukabumi',
      description: 'Soto ayam dengan kuah kuning medok dan koya gurih. Paling pas disantap saat cuaca dingin.',
      rating: 4.8,
      reviewCount: 210,
      priceInfo: 'Seporsi Rp 18k',
      mainImageUrl: 'https://images.unsplash.com/photo-1569562211242-80dda620248a?q=80&w=300',
      galleryImageUrls: ['https://images.unsplash.com/photo-1569562211242-80dda620248a?q=80&w=300'],
      isRecommended: false,
      latitude: -6.921832,
      longitude: 106.934211,
    ),
  ];
  
  // Method untuk mengambil semua restoran
  // Kita simulasikan delay jaringan 1 detik
  Future<List<Restaurant>> getAllRestaurants() async {
    await Future.delayed(const Duration(seconds: 1));
    return _dummyRestaurants;
  }

  // Method untuk mengambil restoran yang direkomendasikan saja
  Future<List<Restaurant>> getRecommendedRestaurants() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _dummyRestaurants.where((resto) => resto.isRecommended).toList();
  }
}