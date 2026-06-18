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

    test('each class has localized title', () {
      for (final rideClass in RideClass.values) {
        expect(rideClass.title, isNotEmpty);
      }
    });
  });

  group('RouteService', () {
    test('calculates price for a ride', () {
      final service = RouteService();
      final price = service.calculatePrice(
        distanceKm: 5,
        durationMinutes: 15,
        rideClass: RideClass.economy,
      );
      expect(price, greaterThan(0));
    });
  });
}
