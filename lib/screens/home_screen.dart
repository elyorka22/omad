import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/ride_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'address_search_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().initLocation();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _openAddressSearch({required bool isPickup}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressSearchScreen(isPickup: isPickup),
      ),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, ride, _) {
        return Scaffold(
          body: Stack(
            children: [
              _TaxiMap(
                mapController: _mapController,
                ride: ride,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _CircleButton(
                        icon: Icons.menu,
                        onTap: _openProfile,
                      ),
                      const Spacer(),
                      if (ride.isLoadingLocation)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Определяем...'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _OrderBottomSheet(
                onPickupTap: () => _openAddressSearch(isPickup: true),
                onDropoffTap: () => _openAddressSearch(isPickup: false),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TaxiMap extends StatelessWidget {
  const _TaxiMap({
    required this.mapController,
    required this.ride,
  });

  final MapController mapController;
  final RideProvider ride;

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[];

    if (ride.pickup != null) {
      markers.add(
        Marker(
          point: ride.pickup!.location,
          width: 80,
          height: 70,
          child: const MapMarkerWidget(
            color: AppColors.pickupMarker,
            label: 'A',
          ),
        ),
      );
    }

    if (ride.dropoff != null) {
      markers.add(
        Marker(
          point: ride.dropoff!.location,
          width: 80,
          height: 70,
          child: const MapMarkerWidget(
            color: AppColors.dropoffMarker,
            label: 'B',
          ),
        ),
      );
    }

    if (ride.driverLocation != null) {
      markers.add(
        Marker(
          point: ride.driverLocation!,
          width: 50,
          height: 60,
          child: const MapMarkerWidget(
            color: AppColors.driverMarker,
            label: '',
            isDriver: true,
          ),
        ),
      );
    }

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: ride.mapCenter,
        initialZoom: 13,
        onPositionChanged: (_, __) {},
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.taxiapp.taxi_app',
        ),
        if (ride.routePoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: ride.routePoints,
                color: AppColors.routeLine,
                strokeWidth: 5,
              ),
            ],
          ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _OrderBottomSheet extends StatelessWidget {
  const _OrderBottomSheet({
    required this.onPickupTap,
    required this.onDropoffTap,
  });

  final VoidCallback onPickupTap;
  final VoidCallback onDropoffTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, ride, _) {
        return DraggableScrollableSheet(
          initialChildSize: _sheetSize(ride.status),
          minChildSize: 0.18,
          maxChildSize: 0.75,
          snap: true,
          snapSizes: const [0.18, 0.45, 0.75],
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContent(context, ride),
                ],
              ),
            );
          },
        );
      },
    );
  }

  double _sheetSize(RideStatus status) {
    switch (status) {
      case RideStatus.idle:
        return 0.45;
      case RideStatus.searching:
      case RideStatus.driverAssigned:
      case RideStatus.driverArriving:
      case RideStatus.inProgress:
        return 0.38;
      case RideStatus.completed:
        return 0.42;
      case RideStatus.cancelled:
        return 0.35;
    }
  }

  Widget _buildContent(BuildContext context, RideProvider ride) {
    switch (ride.status) {
      case RideStatus.idle:
        return _IdleSheet(
          onPickupTap: onPickupTap,
          onDropoffTap: onDropoffTap,
        );
      case RideStatus.searching:
        return _SearchingSheet();
      case RideStatus.driverAssigned:
      case RideStatus.driverArriving:
        return _DriverArrivingSheet();
      case RideStatus.inProgress:
        return _InProgressSheet();
      case RideStatus.completed:
        return _CompletedSheet();
      case RideStatus.cancelled:
        return _CancelledSheet();
    }
  }
}

class _IdleSheet extends StatelessWidget {
  const _IdleSheet({
    required this.onPickupTap,
    required this.onDropoffTap,
  });

  final VoidCallback onPickupTap;
  final VoidCallback onDropoffTap;

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Куда поедем?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              AddressRow(
                icon: Icons.circle,
                iconColor: AppColors.pickupMarker,
                title: ride.pickup?.title ?? 'Откуда',
                subtitle: ride.pickup?.subtitle ?? 'Укажите адрес отправления',
                onTap: onPickupTap,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Container(
                  width: 2,
                  height: 20,
                  color: AppColors.divider,
                ),
              ),
              AddressRow(
                icon: Icons.circle,
                iconColor: AppColors.dropoffMarker,
                title: ride.dropoff?.title ?? 'Куда',
                subtitle: ride.dropoff?.subtitle ?? 'Укажите адрес назначения',
                onTap: onDropoffTap,
                trailing: ride.dropoff != null
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: ride.clearDropoff,
                      )
                    : null,
              ),
            ],
          ),
        ),
        if (ride.dropoff != null) ...[
          const SizedBox(height: 20),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: RideClass.values.length,
              itemBuilder: (context, index) {
                final rideClass = RideClass.values[index];
                return RideClassCard(
                  rideClass: rideClass,
                  price: ride.pricesByClass[rideClass] ?? 0,
                  etaMinutes: rideClass.etaMinutes,
                  isSelected: ride.selectedClass == rideClass,
                  onTap: () => ride.selectRideClass(rideClass),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(
                icon: Icons.route,
                label: '${ride.distanceKm.toStringAsFixed(1)} км',
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.schedule,
                label: '${ride.durationMinutes} мин',
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Заказать · ${ride.estimatedPrice} ₽',
            onPressed: ride.canOrder ? ride.orderRide : null,
            icon: Icons.local_taxi,
          ),
        ],
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _SearchingSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();

    return Column(
      children: [
        const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Ищем водителя...',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          '${ride.selectedClass.title} · ${ride.estimatedPrice} ₽',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: ride.cancelRide,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Отменить'),
        ),
      ],
    );
  }
}

class _DriverArrivingSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();
    final driver = ride.activeOrder?.driver;

    if (driver == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ride.status == RideStatus.driverArriving
              ? 'Водитель едет к вам'
              : 'Водитель назначен',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        DriverCard(
          driver: driver,
          etaText: '${ride.selectedClass.etaMinutes} мин',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.phone),
                label: const Text('Позвонить'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Чат'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: ride.cancelRide,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Отменить поездку'),
        ),
      ],
    );
  }
}

class _InProgressSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'В пути',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'До ${ride.dropoff?.title ?? "назначения"} · ~${ride.durationMinutes} мин',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        if (ride.activeOrder?.driver != null)
          DriverCard(
            driver: ride.activeOrder!.driver!,
            etaText: '${ride.durationMinutes} мин',
          ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: null,
          backgroundColor: AppColors.divider,
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }
}

class _CompletedSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: AppColors.success, size: 36),
        ),
        const SizedBox(height: 16),
        const Text(
          'Поездка завершена',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          '${ride.activeOrder?.price ?? 0} ₽',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Готово',
          onPressed: ride.resetAfterRide,
        ),
      ],
    );
  }
}

class _CancelledSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();

    return Column(
      children: [
        const Icon(Icons.cancel_outlined, color: AppColors.error, size: 48),
        const SizedBox(height: 12),
        const Text(
          'Поездка отменена',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Новый заказ',
          onPressed: ride.resetAfterRide,
        ),
      ],
    );
  }
}
