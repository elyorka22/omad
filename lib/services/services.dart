import 'dart:math';

import 'package:latlong2/latlong.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';

class LocationService {
  static const LatLng moscowCenter = LatLng(55.7558, 37.6173);
  static const LatLng tashkentCenter = LatLng(41.2995, 69.2401);

  static LatLng defaultCenterFor(String languageCode) {
    return languageCode == 'uz' ? tashkentCenter : moscowCenter;
  }

  static final List<Address> moscowPlaces = [
    const Address(
      title: 'Красная площадь',
      subtitle: 'Москва, центр',
      location: LatLng(55.7539, 37.6208),
    ),
    const Address(
      title: 'ВДНХ',
      subtitle: 'Проспект Мира, 119',
      location: LatLng(55.8263, 37.6378),
    ),
    const Address(
      title: 'Москва-Сити',
      subtitle: 'Пресненская наб., 10',
      location: LatLng(55.7496, 37.5396),
    ),
    const Address(
      title: 'Парк Горького',
      subtitle: 'Крымский Вал, 9',
      location: LatLng(55.7310, 37.6014),
    ),
    const Address(
      title: 'Шереметьево',
      subtitle: 'Международный аэропорт',
      location: LatLng(55.9726, 37.4146),
    ),
    const Address(
      title: 'Лужники',
      subtitle: 'Лужнецкая наб., 24',
      location: LatLng(55.7157, 37.5537),
    ),
  ];

  static final List<Address> tashkentPlaces = [
    const Address(
      title: 'Mustaqillik maydoni',
      subtitle: 'Toshkent, markaz',
      location: LatLng(41.3111, 69.2797),
    ),
    const Address(
      title: 'Toshkent metro',
      subtitle: 'Amir Temur ko\'chasi',
      location: LatLng(41.3110, 69.2405),
    ),
    const Address(
      title: 'Chorsu bozori',
      subtitle: 'Beruniy ko\'chasi',
      location: LatLng(41.3268, 69.2347),
    ),
    const Address(
      title: 'Tashkent City',
      subtitle: 'Islom Karimov ko\'chasi',
      location: LatLng(41.3180, 69.2510),
    ),
    const Address(
      title: 'Toshkent aeroporti',
      subtitle: 'Xalqaro aeroport',
      location: LatLng(41.2579, 69.2812),
    ),
    const Address(
      title: 'Magic City',
      subtitle: 'Kichik halqa yo\'li',
      location: LatLng(41.2950, 69.2030),
    ),
  ];

  List<Address> popularPlacesFor(String languageCode) {
    return languageCode == 'uz' ? tashkentPlaces : moscowPlaces;
  }

  List<Address> searchAddresses(String query, String languageCode) {
    final places = popularPlacesFor(languageCode);
    if (query.trim().isEmpty) {
      return places;
    }
    final lower = query.toLowerCase();
    return places
        .where(
          (place) =>
              place.title.toLowerCase().contains(lower) ||
              place.subtitle.toLowerCase().contains(lower),
        )
        .toList();
  }

  Address addressNear(LatLng location, AppLocalizations l10n) {
    final places = popularPlacesFor(l10n.languageCode);
    Address? nearest;
    double minDistance = double.infinity;

    for (final place in places) {
      final distance = const Distance().as(
        LengthUnit.Kilometer,
        location,
        place.location,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearest = place;
      }
    }

    return nearest?.copyWith(
          title: l10n.currentLocation,
          subtitle: nearest.title,
          location: location,
        ) ??
        Address(
          title: l10n.currentLocation,
          subtitle:
              '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
          location: location,
        );
  }
}

class RouteService {
  double calculateDistanceKm(LatLng from, LatLng to) {
    return const Distance().as(LengthUnit.Kilometer, from, to);
  }

  int calculateDurationMinutes(double distanceKm) {
    final baseMinutes = (distanceKm / 0.5).ceil();
    return max(3, baseMinutes);
  }

  int calculatePrice({
    required double distanceKm,
    required int durationMinutes,
    required RideClass rideClass,
    required String languageCode,
  }) {
    final baseFare = languageCode == 'uz' ? 5000 : 99;
    final perKm = languageCode == 'uz' ? 2500 : 18;
    final perMinute = languageCode == 'uz' ? 500 : 5;

    final raw = baseFare +
        (distanceKm * perKm).round() +
        (durationMinutes * perMinute);

    return (raw * rideClass.priceMultiplier).round();
  }

  List<LatLng> buildRoutePoints(LatLng from, LatLng to) {
    final points = <LatLng>[from];
    const steps = 12;
    final random = Random(from.latitude.hashCode ^ to.longitude.hashCode);

    for (var i = 1; i < steps; i++) {
      final t = i / steps;
      final lat = from.latitude + (to.latitude - from.latitude) * t;
      final lng = from.longitude + (to.longitude - from.longitude) * t;
      final offset = (random.nextDouble() - 0.5) * 0.004;
      points.add(LatLng(lat + offset, lng + offset * 0.7));
    }

    points.add(to);
    return points;
  }

  LatLng interpolate(LatLng from, LatLng to, double progress) {
    return LatLng(
      from.latitude + (to.latitude - from.latitude) * progress,
      from.longitude + (to.longitude - from.longitude) * progress,
    );
  }
}

class DriverService {
  final _driversRu = [
    const Driver(
      id: 'd1',
      name: 'Алексей',
      carModel: 'Kia Rio',
      carNumber: 'А123ВС777',
      rating: 4.92,
      location: LatLng(55.7580, 37.6150),
      photoEmoji: '👨‍✈️',
    ),
    const Driver(
      id: 'd2',
      name: 'Дмитрий',
      carModel: 'Hyundai Solaris',
      carNumber: 'В456КХ199',
      rating: 4.88,
      location: LatLng(55.7520, 37.6220),
      photoEmoji: '👨',
    ),
    const Driver(
      id: 'd3',
      name: 'Мария',
      carModel: 'Toyota Camry',
      carNumber: 'С789МН777',
      rating: 4.95,
      location: LatLng(55.7610, 37.6080),
      photoEmoji: '👩‍✈️',
    ),
  ];

  final _driversUz = [
    const Driver(
      id: 'u1',
      name: 'Jasur',
      carModel: 'Chevrolet Cobalt',
      carNumber: '01A123BC',
      rating: 4.91,
      location: LatLng(41.3050, 69.2450),
      photoEmoji: '👨‍✈️',
    ),
    const Driver(
      id: 'u2',
      name: 'Sardor',
      carModel: 'Daewoo Nexia',
      carNumber: '01B456DE',
      rating: 4.87,
      location: LatLng(41.2980, 69.2520),
      photoEmoji: '👨',
    ),
    const Driver(
      id: 'u3',
      name: 'Dilnoza',
      carModel: 'Toyota Camry',
      carNumber: '01C789FG',
      rating: 4.96,
      location: LatLng(41.3120, 69.2380),
      photoEmoji: '👩‍✈️',
    ),
  ];

  Driver findNearestDriver(
    LatLng pickup,
    RideClass rideClass,
    String languageCode,
  ) {
    final drivers = languageCode == 'uz' ? _driversUz : _driversRu;
    final index = rideClass.index % drivers.length;
    final driver = drivers[index];
    return Driver(
      id: driver.id,
      name: driver.name,
      carModel: driver.carModel,
      carNumber: driver.carNumber,
      rating: driver.rating,
      location: LatLng(
        pickup.latitude + 0.008,
        pickup.longitude - 0.006,
      ),
      photoEmoji: driver.photoEmoji,
    );
  }
}
