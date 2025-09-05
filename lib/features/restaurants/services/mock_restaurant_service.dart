// lib/features/restaurants/services/mock_restaurant_service.dart

import 'package:suka_emam_app/features/restaurants/models/restaurant.dart';

class MockRestaurantService {
  final List<Restaurant> _dummyRestaurants = [
    Restaurant(
      id: 1,
      name: 'Mie Goreng Mang Roy',
      categories: ['Mie', 'Jajanan', 'Kaki Lima'],
      shortAddress: 'Alun Alun Sukabumi',
      fullAddress: 'Jl. Alun-Alun Utara No. 1, Sukabumi',
      description:
          'Mie goreng legendaris dengan bumbu khas yang bikin nagih. Porsi melimpah, harga bersahabat.',
      rating: 4.5,
      reviewCount: 152,
      priceInfo: 'Mulai dari Rp 15k/porsi',
      mainImageUrl: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?q=80&w=600',
      galleryImageUrls: [
        'https://images.unsplash.com/photo-1585032226651-759b368d7246?q=80&w=600'
      ],
      latitude: -6.921832,
      longitude: 106.934211,
      isRecommended: true,
    ),
    Restaurant(
      id: 2,
      name: 'Warteg Bahari',
      categories: ['Nasi', 'Ayam', 'Minuman'],
      shortAddress: 'Benteng, Sukabumi',
      fullAddress: 'Jl. Benteng No. 45, Warudoyong, Sukabumi',
      description:
          'Murah banget bang, ceban paket kenyang. Pilihan lauknya banyak dan rasanya otentik.',
      rating: 4.4,
      reviewCount: 105,
      priceInfo: 'Mulai dari Rp 10k/porsi',
      mainImageUrl: 'https://images.unsplash.com/photo-1568205934931-a2260f8197b3?q=80&w=600',
      galleryImageUrls: [
        'https://images.unsplash.com/photo-1568205934931-a2260f8197b3?q=80&w=600',
        'https://images.unsplash.com/photo-1625944228741-cf3b93a52194?q=80&w=600',
      ],
      latitude: -6.925501,
      longitude: 106.927423,
      isRecommended: true,
    ),
    Restaurant(
      id: 3,
      name: 'Soto Ayam Asli Lamongan',
      categories: ['Soto', 'Ayam', 'Berkuah'],
      shortAddress: 'Ciaul, Sukabumi',
      fullAddress: 'Jl. R.A. Kosasih No. 101, Ciaul, Sukabumi',
      description:
          'Soto ayam dengan kuah kuning medok dan koya gurih. Paling pas disantap saat cuaca dingin.',
      rating: 4.8,
      reviewCount: 210,
      priceInfo: 'Seporsi Rp 18k',
      mainImageUrl: 'https://images.unsplash.com/photo-1569562211242-80dda620248a?q=80&w=600',
      galleryImageUrls: [
        'https://images.unsplash.com/photo-1569562211242-80dda620248a?q=80&w=600'
      ],
      latitude: -6.915203,
      longitude: 106.935812,
      isRecommended: false,
    ),
    // --- DATA BARU ---
    Restaurant(
      id: 4,
      name: 'Kopi Anjis Sukabumi',
      categories: ['Kopi', 'Kafe', 'Nongkrong'],
      shortAddress: 'Cikole, Sukabumi',
      fullAddress: 'Jl. Siliwangi No. 75, Cikole, Sukabumi',
      description: 'Tempat ngopi hits dengan suasana cozy dan pilihan biji kopi nusantara. Cocok buat kerja atau sekedar santai.',
      rating: 4.7,
      reviewCount: 250,
      priceInfo: 'Mulai dari Rp 20k',
      mainImageUrl: 'https://images.unsplash.com/photo-1511920183276-5941b2e6e5e3?q=80&w=600',
      galleryImageUrls: [
        'https://images.unsplash.com/photo-1511920183276-5941b2e6e5e3?q=80&w=600'
      ],
      latitude: -6.9188,
      longitude: 106.9295,
      isRecommended: true,
    ),
     Restaurant(
      id: 5,
      name: 'Saung Ranggon',
      categories: ['Sunda', 'Keluarga', 'Lesehan'],
      shortAddress: 'Salabintana, Sukabumi',
      fullAddress: 'Jl. Salabintana KM 7, Sudajaya Girang, Sukabumi',
      description: 'Nikmati masakan khas Sunda di saung-saung bambu dengan pemandangan alam yang asri. Menu andalan: Nasi Liwet Komplit.',
      rating: 4.6,
      reviewCount: 188,
      priceInfo: 'Paket mulai Rp 100k/4 org',
      mainImageUrl: 'https://images.unsplash.com/photo-1625944228741-cf3b93a52194?q=80&w=600',
      galleryImageUrls: [
        'https://images.unsplash.com/photo-1625944228741-cf3b93a52194?q=80&w=600'
      ],
      latitude: -6.872,
      longitude: 106.941,
      isRecommended: false,
    ),
    Restaurant(
      id: 6,
      name: 'Mochi Kaswari Lampion',
      categories: ['Oleh-oleh', 'Kue', 'Jajanan'],
      shortAddress: 'Bhayangkara, Sukabumi',
      fullAddress: 'Jl. Bhayangkara Gg. Kaswari, Selabatu, Sukabumi',
      description: 'Pusat oleh-oleh khas Sukabumi. Mochi dengan isian legit dan beragam rasa yang legendaris.',
      rating: 4.9,
      reviewCount: 530,
      priceInfo: 'Satu kotak Rp 35k',
      mainImageUrl: 'https://images.unsplash.com/photo-1603874948496-e340d85b3f07?q=80&w=600',
      galleryImageUrls: [
        'https://images.unsplash.com/photo-1603874948496-e340d85b3f07?q=80&w=600'
      ],
      latitude: -6.914,
      longitude: 106.924,
      isRecommended: true,
    ),
  ];

  Future<List<Restaurant>> getAllRestaurants() async {
    await Future.delayed(const Duration(seconds: 1));
    return _dummyRestaurants;
  }

  Future<List<Restaurant>> getRecommendedRestaurants() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _dummyRestaurants.where((resto) => resto.isRecommended).toList();
  }
}