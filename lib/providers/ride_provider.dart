import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/services.dart';

class RideProvider extends ChangeNotifier {
  RideProvider({
    LocationService? locationService,
    RouteService? routeService,
    DriverService? driverService,
  })  : _locationService = locationService ?? LocationService(),
        _routeService = routeService ?? RouteService(),
        _driverService = driverService ?? DriverService();

  final LocationService _locationService;
  final RouteService _routeService;
  final DriverService _driverService;
  final _uuid = const Uuid();

  String _languageCode = 'ru';
  LatLng _mapCenter = LocationService.moscowCenter;
  LatLng? _userLocation;
  Address? _pickup;
  Address? _dropoff;
  RideClass _selectedClass = RideClass.economy;
  RideStatus _status = RideStatus.idle;
  RideOrder? _activeOrder;
  List<LatLng> _routePoints = [];
  LatLng? _driverLocation;
  double _driverProgress = 0;
  bool _isLoadingLocation = false;
  String? _locationError;
  Timer? _simulationTimer;

  List<RideHistoryItem> _history = [];

  String get languageCode => _languageCode;
  LatLng get mapCenter => _mapCenter;
  LatLng? get userLocation => _userLocation;
  Address? get pickup => _pickup;
  Address? get dropoff => _dropoff;
  RideClass get selectedClass => _selectedClass;
  RideStatus get status => _status;
  RideOrder? get activeOrder => _activeOrder;
  List<LatLng> get routePoints => _routePoints;
  LatLng? get driverLocation => _driverLocation;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get locationError => _locationError;
  List<RideHistoryItem> get history => List.unmodifiable(_history);

  bool get canOrder =>
      _pickup != null && _dropoff != null && _status == RideStatus.idle;

  bool get showPickupMarker {
    if (_pickup == null || _userLocation == null) return _pickup != null;
    return _distanceBetween(_pickup!.location, _userLocation!) > 0.00015;
  }

  double _distanceBetween(LatLng a, LatLng b) {
    return (a.latitude - b.latitude).abs() +
        (a.longitude - b.longitude).abs();
  }

  double get distanceKm {
    if (_pickup == null || _dropoff == null) return 0;
    return _routeService.calculateDistanceKm(
      _pickup!.location,
      _dropoff!.location,
    );
  }

  int get durationMinutes {
    return _routeService.calculateDurationMinutes(distanceKm);
  }

  int get estimatedPrice {
    return _routeService.calculatePrice(
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      rideClass: _selectedClass,
      languageCode: _languageCode,
    );
  }

  Map<RideClass, int> get pricesByClass {
    return {
      for (final rideClass in RideClass.values)
        rideClass: _routeService.calculatePrice(
          distanceKm: distanceKm,
          durationMinutes: durationMinutes,
          rideClass: rideClass,
          languageCode: _languageCode,
        ),
    };
  }

  void updateLanguage(String languageCode, AppLocalizations l10n) {
    if (_languageCode == languageCode) return;
    _languageCode = languageCode;
    _mapCenter = LocationService.defaultCenterFor(languageCode);
    _initDemoHistory(l10n);

    if (_userLocation != null) {
      _pickup = _locationService.addressNear(_userLocation!, l10n);
    } else {
      _pickup = null;
    }
    _dropoff = null;
    _routePoints = [];
    notifyListeners();
  }

  void _initDemoHistory(AppLocalizations l10n) {
    if (l10n.isUzbek) {
      _history = [
        RideHistoryItem(
          id: 'h1',
          from: 'Uy',
          to: 'Ofis',
          price: 28000,
          date: DateTime.now().subtract(const Duration(days: 1)),
          rideClass: RideClass.comfort,
        ),
        RideHistoryItem(
          id: 'h2',
          from: 'Chorsu bozori',
          to: 'Toshkent aeroporti',
          price: 65000,
          date: DateTime.now().subtract(const Duration(days: 3)),
          rideClass: RideClass.economy,
        ),
      ];
    } else {
      _history = [
        RideHistoryItem(
          id: 'h1',
          from: 'Дом',
          to: 'Офис',
          price: 420,
          date: DateTime.now().subtract(const Duration(days: 1)),
          rideClass: RideClass.comfort,
        ),
        RideHistoryItem(
          id: 'h2',
          from: 'ТЦ Европейский',
          to: 'Аэропорт Шереметьево',
          price: 1890,
          date: DateTime.now().subtract(const Duration(days: 3)),
          rideClass: RideClass.economy,
        ),
      ];
    }
  }

  Future<LatLng?> initLocation(AppLocalizations l10n) async {
    _languageCode = l10n.languageCode;
    _initDemoHistory(l10n);
    return refreshMyLocation(l10n, updatePickup: true);
  }

  Future<LatLng?> refreshMyLocation(
    AppLocalizations l10n, {
    bool updatePickup = false,
  }) async {
    _isLoadingLocation = true;
    _locationError = null;
    notifyListeners();

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _locationError = l10n.noLocationPermission;
        final fallback = LocationService.defaultCenterFor(_languageCode);
        _userLocation = fallback;
        _mapCenter = fallback;
        if (updatePickup || _pickup == null) {
          _pickup = _locationService.addressNear(fallback, l10n);
        }
      } else {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
          ),
        );
        final location = LatLng(position.latitude, position.longitude);
        _userLocation = location;
        _mapCenter = location;
        if (updatePickup || _pickup == null) {
          _pickup = _locationService.addressNear(location, l10n);
        }
      }
    } catch (e) {
      _locationError = l10n.locationFailed;
      final fallback = LocationService.defaultCenterFor(_languageCode);
      _userLocation = fallback;
      _mapCenter = fallback;
      if (updatePickup || _pickup == null) {
        _pickup = _locationService.addressNear(fallback, l10n);
      }
    }

    _isLoadingLocation = false;
    notifyListeners();
    return _userLocation;
  }

  void setPickup(Address address) {
    _pickup = address;
    _mapCenter = address.location;
    _rebuildRoute();
    notifyListeners();
  }

  void setDropoff(Address address) {
    _dropoff = address;
    _rebuildRoute();
    notifyListeners();
  }

  void clearDropoff() {
    _dropoff = null;
    _routePoints = [];
    notifyListeners();
  }

  void selectRideClass(RideClass rideClass) {
    _selectedClass = rideClass;
    notifyListeners();
  }

  void _rebuildRoute() {
    if (_pickup != null && _dropoff != null) {
      _routePoints = _routeService.buildRoutePoints(
        _pickup!.location,
        _dropoff!.location,
      );
    } else {
      _routePoints = [];
    }
  }

  Future<void> orderRide() async {
    if (!canOrder) return;

    final order = RideOrder(
      id: _uuid.v4(),
      pickup: _pickup!,
      dropoff: _dropoff!,
      rideClass: _selectedClass,
      price: estimatedPrice,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      status: RideStatus.searching,
      createdAt: DateTime.now(),
    );

    _activeOrder = order;
    _status = RideStatus.searching;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final driver = _driverService.findNearestDriver(
      _pickup!.location,
      _selectedClass,
      _languageCode,
    );
    _activeOrder = order.copyWith(
      status: RideStatus.driverAssigned,
      driver: driver,
    );
    _status = RideStatus.driverAssigned;
    _driverLocation = driver.location;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));
    _status = RideStatus.driverArriving;
    _activeOrder = _activeOrder!.copyWith(status: RideStatus.driverArriving);
    notifyListeners();

    _startDriverSimulation(toPickup: true);
  }

  void _startDriverSimulation({required bool toPickup}) {
    _simulationTimer?.cancel();
    _driverProgress = 0;

    final start = _driverLocation ?? _activeOrder!.driver!.location;
    final end =
        toPickup ? _activeOrder!.pickup.location : _activeOrder!.dropoff.location;

    _simulationTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      _driverProgress += 0.02;
      if (_driverProgress >= 1) {
        _driverProgress = 1;
        _driverLocation = end;
        timer.cancel();

        if (toPickup) {
          _status = RideStatus.inProgress;
          _activeOrder = _activeOrder!.copyWith(status: RideStatus.inProgress);
          notifyListeners();
          Future.delayed(const Duration(milliseconds: 500), () {
            _startDriverSimulation(toPickup: false);
          });
        } else {
          _completeRide();
        }
      } else {
        _driverLocation = _routeService.interpolate(start, end, _driverProgress);
      }
      notifyListeners();
    });
  }

  void _completeRide() {
    _status = RideStatus.completed;
    _activeOrder = _activeOrder!.copyWith(status: RideStatus.completed);

    _history.insert(
      0,
      RideHistoryItem(
        id: _activeOrder!.id,
        from: _activeOrder!.pickup.title,
        to: _activeOrder!.dropoff.title,
        price: _activeOrder!.price,
        date: DateTime.now(),
        rideClass: _activeOrder!.rideClass,
      ),
    );

    notifyListeners();
  }

  void cancelRide() {
    _simulationTimer?.cancel();
    _status = RideStatus.cancelled;
    if (_activeOrder != null) {
      _activeOrder = _activeOrder!.copyWith(status: RideStatus.cancelled);
    }
    notifyListeners();
  }

  void resetAfterRide() {
    _simulationTimer?.cancel();
    _status = RideStatus.idle;
    _activeOrder = null;
    _driverLocation = null;
    _driverProgress = 0;
    _dropoff = null;
    _routePoints = [];
    notifyListeners();
  }

  List<Address> searchAddresses(String query) {
    return _locationService.searchAddresses(query, _languageCode);
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
