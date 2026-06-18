import 'dart:math';

import 'package:latlong2/latlong.dart';

import '../models/models.dart';

class LocationService {
  static const LatLng defaultCenter = LatLng(55.7558, 37.6173);

  static final List<Address> popularPlaces = [
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
    const Address(
      title: 'Третьяковская галерея',
      subtitle: 'Лаврушинский пер., 10',
      location: LatLng(55.7414, 37.6208),
    ),
    const Address(
      title: 'Внуково',
      subtitle: 'Международный аэропорт',
      location: LatLng(55.5965, 37.2615),
    ),
  ];

  List<Address> searchAddresses(String query) {
    if (query.trim().isEmpty) {
      return popularPlaces;
    }
    final lower = query.toLowerCase();
    return popularPlaces
        .where(
          (place) =>
              place.title.toLowerCase().contains(lower) ||
              place.subtitle.toLowerCase().contains(lower),
        )
        .toList();
  }

  Address addressNear(LatLng location) {
    Address? nearest;
    double minDistance = double.infinity;

    for (final place in popularPlaces) {
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
          title: 'Текущее местоположение',
          subtitle: nearest.title,
          location: location,
        ) ??
        Address(
          title: 'Текущее местоположение',
          subtitle: '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
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
  }) {
    const baseFare = 99;
    const perKm = 18;
    const perMinute = 5;

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
  final _drivers = [
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
    const Driver(
      id: 'd4',
      name: 'Игорь',
      carModel: 'Mercedes E-class',
      carNumber: 'Е321ОР777',
      rating: 4.97,
      location: LatLng(55.7480, 37.6300),
      photoEmoji: '🧑‍✈️',
    ),
  ];

  Driver findNearestDriver(LatLng pickup, RideClass rideClass) {
    final index = rideClass.index % _drivers.length;
    final driver = _drivers[index];
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
