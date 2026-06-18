import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

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

  LatLng _mapCenter = LocationService.defaultCenter;
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

  final List<RideHistoryItem> _history = [
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
    RideHistoryItem(
      id: 'h3',
      from: 'Ресторан',
      to: 'Дом',
      price: 650,
      date: DateTime.now().subtract(const Duration(days: 5)),
      rideClass: RideClass.comfortPlus,
    ),
  ];

  LatLng get mapCenter => _mapCenter;
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

  bool get canOrder => _pickup != null && _dropoff != null && _status == RideStatus.idle;

  double get distanceKm {
    if (_pickup == null || _dropoff == null) return 0;
    return _routeService.calculateDistanceKm(_pickup!.location, _dropoff!.location);
  }

  int get durationMinutes {
    return _routeService.calculateDurationMinutes(distanceKm);
  }

  int get estimatedPrice {
    return _routeService.calculatePrice(
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      rideClass: _selectedClass,
    );
  }

  Map<RideClass, int> get pricesByClass {
    return {
      for (final rideClass in RideClass.values)
        rideClass: _routeService.calculatePrice(
          distanceKm: distanceKm,
          durationMinutes: durationMinutes,
          rideClass: rideClass,
        ),
    };
  }

  Future<void> initLocation() async {
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
        _locationError = 'Нет доступа к геолокации';
        _pickup = _locationService.addressNear(LocationService.defaultCenter);
        _mapCenter = LocationService.defaultCenter;
      } else {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
          ),
        );
        final location = LatLng(position.latitude, position.longitude);
        _mapCenter = location;
        _pickup = _locationService.addressNear(location);
      }
    } catch (e) {
      _locationError = 'Не удалось определить местоположение';
      _pickup = _locationService.addressNear(LocationService.defaultCenter);
      _mapCenter = LocationService.defaultCenter;
    }

    _isLoadingLocation = false;
    notifyListeners();
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

    final driver = _driverService.findNearestDriver(_pickup!.location, _selectedClass);
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
    final end = toPickup ? _activeOrder!.pickup.location : _activeOrder!.dropoff.location;

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
    return _locationService.searchAddresses(query);
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
