import 'package:latlong2/latlong.dart';

enum RideStatus {
  idle,
  searching,
  driverAssigned,
  driverArriving,
  inProgress,
  completed,
  cancelled,
}

enum RideClass {
  economy,
  comfort,
  comfortPlus,
  business,
}

extension RideClassExtension on RideClass {
  String get title {
    switch (this) {
      case RideClass.economy:
        return 'Эконом';
      case RideClass.comfort:
        return 'Комфорт';
      case RideClass.comfortPlus:
        return 'Комфорт+';
      case RideClass.business:
        return 'Бизнес';
    }
  }

  String get description {
    switch (this) {
      case RideClass.economy:
        return 'Недорогие поездки';
      case RideClass.comfort:
        return 'Новые автомобили';
      case RideClass.comfortPlus:
        return 'Просторные авто';
      case RideClass.business:
        return 'Премиум-класс';
    }
  }

  String get icon {
    switch (this) {
      case RideClass.economy:
        return '🚗';
      case RideClass.comfort:
        return '🚙';
      case RideClass.comfortPlus:
        return '🚐';
      case RideClass.business:
        return '🏎️';
    }
  }

  double get priceMultiplier {
    switch (this) {
      case RideClass.economy:
        return 1.0;
      case RideClass.comfort:
        return 1.35;
      case RideClass.comfortPlus:
        return 1.7;
      case RideClass.business:
        return 2.2;
    }
  }

  int get etaMinutes {
    switch (this) {
      case RideClass.economy:
        return 4;
      case RideClass.comfort:
        return 6;
      case RideClass.comfortPlus:
        return 8;
      case RideClass.business:
        return 10;
    }
  }
}

class Address {
  const Address({
    required this.title,
    required this.subtitle,
    required this.location,
  });

  final String title;
  final String subtitle;
  final LatLng location;

  Address copyWith({
    String? title,
    String? subtitle,
    LatLng? location,
  }) {
    return Address(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      location: location ?? this.location,
    );
  }
}

class Driver {
  const Driver({
    required this.id,
    required this.name,
    required this.carModel,
    required this.carNumber,
    required this.rating,
    required this.location,
    required this.photoEmoji,
  });

  final String id;
  final String name;
  final String carModel;
  final String carNumber;
  final double rating;
  final LatLng location;
  final String photoEmoji;
}

class RideOrder {
  const RideOrder({
    required this.id,
    required this.pickup,
    required this.dropoff,
    required this.rideClass,
    required this.price,
    required this.distanceKm,
    required this.durationMinutes,
    required this.status,
    this.driver,
    this.createdAt,
  });

  final String id;
  final Address pickup;
  final Address dropoff;
  final RideClass rideClass;
  final int price;
  final double distanceKm;
  final int durationMinutes;
  final RideStatus status;
  final Driver? driver;
  final DateTime? createdAt;

  RideOrder copyWith({
    String? id,
    Address? pickup,
    Address? dropoff,
    RideClass? rideClass,
    int? price,
    double? distanceKm,
    int? durationMinutes,
    RideStatus? status,
    Driver? driver,
    DateTime? createdAt,
  }) {
    return RideOrder(
      id: id ?? this.id,
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      rideClass: rideClass ?? this.rideClass,
      price: price ?? this.price,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      driver: driver ?? this.driver,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class RideHistoryItem {
  const RideHistoryItem({
    required this.id,
    required this.from,
    required this.to,
    required this.price,
    required this.date,
    required this.rideClass,
  });

  final String id;
  final String from;
  final String to;
  final int price;
  final DateTime date;
  final RideClass rideClass;
}
