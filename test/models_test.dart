import 'package:flutter_test/flutter_test.dart';
import 'package:taxi_app/models/models.dart';
import 'package:taxi_app/services/services.dart';

void main() {
  group('RideClass', () {
    test('economy has base price multiplier', () {
      expect(RideClass.economy.priceMultiplier, 1.0);
    });

    test('business has highest price multiplier', () {
      expect(
        RideClass.business.priceMultiplier,
        greaterThan(RideClass.economy.priceMultiplier),
      );
    });

    test('each class has localized title in extension', () {
      for (final rideClass in RideClass.values) {
        expect(rideClass.title, isNotEmpty);
      }
    });
  });

  group('RouteService', () {
    test('calculates price for a ride in Russian locale', () {
      final service = RouteService();
      final price = service.calculatePrice(
        distanceKm: 5,
        durationMinutes: 15,
        rideClass: RideClass.economy,
        languageCode: 'ru',
      );
      expect(price, greaterThan(0));
    });

    test('calculates price for a ride in Uzbek locale', () {
      final service = RouteService();
      final price = service.calculatePrice(
        distanceKm: 5,
        durationMinutes: 15,
        rideClass: RideClass.economy,
        languageCode: 'uz',
      );
      expect(price, greaterThan(0));
    });
  });
}
