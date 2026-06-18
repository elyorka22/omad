import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/locale_provider.dart';
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
  bool _locationButtonActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final l10n = AppLocalizations.of(context);
      final ride = context.read<RideProvider>();
      final location = await ride.initLocation(l10n);
      if (location != null && mounted) {
        _mapController.move(location, 14);
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _goToMyLocation() async {
    final l10n = AppLocalizations.of(context);
    final ride = context.read<RideProvider>();
    setState(() => _locationButtonActive = true);

    final location = await ride.refreshMyLocation(l10n, updatePickup: true);
    if (location != null && mounted) {
      _mapController.move(location, 16);
    }

    if (mounted) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _locationButtonActive = false);
      });
    }
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
    final l10n = AppLocalizations.of(context);
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Consumer2<RideProvider, LocaleProvider>(
      builder: (context, ride, localeProvider, _) {
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
                      _LanguageChip(
                        label: localeProvider.locale.languageCode == 'uz'
                            ? 'UZ'
                            : 'RU',
                        onTap: () {
                          if (localeProvider.locale.languageCode == 'uz') {
                            localeProvider.setRussian();
                            ride.updateLanguage('ru', AppLocalizations('ru'));
                          } else {
                            localeProvider.setUzbek();
                            ride.updateLanguage('uz', AppLocalizations('uz'));
                          }
                          _mapController.move(ride.mapCenter, 13);
                        },
                      ),
                      if (ride.isLoadingLocation) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 8),
                              Text(l10n.detecting),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: screenHeight * 0.47,
                child: MapFloatingButton(
                  icon: Icons.my_location,
                  isActive: _locationButtonActive,
                  tooltip: l10n.myLocation,
                  onTap: ride.isLoadingLocation ? () {} : _goToMyLocation,
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

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      shadowColor: AppColors.accent.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.brandGradient.createShader(bounds),
                child: const Icon(Icons.language, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
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

    if (ride.userLocation != null) {
      markers.add(
        Marker(
          point: ride.userLocation!,
          width: 48,
          height: 48,
          child: const UserLocationMarker(),
        ),
      );
    }

    if (ride.showPickupMarker && ride.pickup != null) {
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
        initialZoom: 14,
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
                borderColor: AppColors.accentViolet.withValues(alpha: 0.4),
                borderStrokeWidth: 2,
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
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(3),
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
        return const _SearchingSheet();
      case RideStatus.driverAssigned:
      case RideStatus.driverArriving:
        return const _DriverArrivingSheet();
      case RideStatus.inProgress:
        return const _InProgressSheet();
      case RideStatus.completed:
        return const _CompletedSheet();
      case RideStatus.cancelled:
        return const _CancelledSheet();
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
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.whereToGo,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              AddressRow(
                icon: Icons.circle,
                iconColor: AppColors.pickupMarker,
                title: ride.pickup?.title ?? l10n.from,
                subtitle: ride.pickup?.subtitle ?? l10n.specifyPickup,
                onTap: onPickupTap,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Container(
                  width: 2,
                  height: 24,
                  color: AppColors.divider,
                ),
              ),
              AddressRow(
                icon: Icons.circle,
                iconColor: AppColors.dropoffMarker,
                title: ride.dropoff?.title ?? l10n.to,
                subtitle: ride.dropoff?.subtitle ?? l10n.specifyDropoff,
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
            height: 136,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: RideClass.values.length,
              itemBuilder: (context, index) {
                final rideClass = RideClass.values[index];
                return RideClassCard(
                  rideClass: rideClass,
                  title: l10n.rideClassName(rideClass),
                  priceLabel: l10n.formatPrice(
                    ride.pricesByClass[rideClass] ?? 0,
                  ),
                  etaLabel: l10n.minutesLabel(rideClass.etaMinutes),
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
                label: l10n.distanceLabel(ride.distanceKm),
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.schedule,
                label: l10n.minutesLabel(ride.durationMinutes),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: l10n.orderButtonLabel(ride.estimatedPrice),
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
  const _SearchingSheet();

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();
    final l10n = AppLocalizations.of(context);

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
        Text(
          l10n.searchingDriver,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          '${l10n.rideClassName(ride.selectedClass)} · ${l10n.formatPrice(ride.estimatedPrice)}',
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
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}

class _DriverArrivingSheet extends StatelessWidget {
  const _DriverArrivingSheet();

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();
    final l10n = AppLocalizations.of(context);
    final driver = ride.activeOrder?.driver;

    if (driver == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ride.status == RideStatus.driverArriving
              ? l10n.driverComing
              : l10n.driverAssigned,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        DriverCard(
          driver: driver,
          etaText: l10n.minutesLabel(ride.selectedClass.etaMinutes),
          arrivalLabel: l10n.arrival,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.phone),
                label: Text(l10n.call),
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
                label: Text(l10n.chat),
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
          child: Text(l10n.cancelRide),
        ),
      ],
    );
  }
}

class _InProgressSheet extends StatelessWidget {
  const _InProgressSheet();

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.inProgress,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.inProgressLabel(
            ride.dropoff?.title ?? l10n.destination,
            ride.durationMinutes,
          ),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        if (ride.activeOrder?.driver != null)
          DriverCard(
            driver: ride.activeOrder!.driver!,
            etaText: l10n.minutesLabel(ride.durationMinutes),
            arrivalLabel: l10n.arrival,
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
  const _CompletedSheet();

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: AppColors.success, size: 36),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.rideCompleted,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.formatPrice(ride.activeOrder?.price ?? 0),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: l10n.done,
          onPressed: ride.resetAfterRide,
        ),
      ],
    );
  }
}

class _CancelledSheet extends StatelessWidget {
  const _CancelledSheet();

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        const Icon(Icons.cancel_outlined, color: AppColors.error, size: 48),
        const SizedBox(height: 12),
        Text(
          l10n.rideCancelled,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: l10n.newOrder,
          onPressed: ride.resetAfterRide,
        ),
      ],
    );
  }
}
