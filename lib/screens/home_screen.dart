import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/locale_provider.dart';
import '../providers/ride_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../widgets/yandex_ui.dart';
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

    final location = await ride.refreshMyLocation(l10n, updatePickup: true);
    if (location != null && mounted) {
      _mapController.move(location, 16);
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
      builder: (context, ride, _, _) {
        return Scaffold(
          body: Stack(
            children: [
              _TaxiMap(
                mapController: _mapController,
                ride: ride,
                pickupEtaLabel: l10n.pickupEtaLabel(4),
                onMapTap: ride.isMapPicking
                    ? (point) {
                        ride.applyMapLocation(point, l10n);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.selectedOnMap),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    : null,
              ),
              SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      left: 56,
                      right: 56,
                      child: YandexTopAddressBar(
                        label: l10n.yourAddress,
                        address: ride.pickup?.title ?? l10n.detecting,
                        onTap: () => _openAddressSearch(isPickup: true),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                bottom: ride.isMapPicking
                    ? screenHeight * 0.34
                    : screenHeight * 0.30,
                child: YandexWhiteFab(
                  icon: Icons.menu,
                  onTap: _openProfile,
                ),
              ),
              Positioned(
                right: 16,
                bottom: ride.isMapPicking
                    ? screenHeight * 0.34
                    : screenHeight * 0.30,
                child: YandexWhiteFab(
                  icon: Icons.near_me,
                  onTap: ride.isLoadingLocation ? () {} : _goToMyLocation,
                ),
              ),
              if (ride.isMapPicking)
                IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.06),
                      child: MapCenterPin(
                        color: ride.mapPickTarget == MapPickTarget.pickup
                            ? AppColors.pickupMarker
                            : AppColors.dropoffMarker,
                        label: ride.mapPickTarget == MapPickTarget.pickup
                            ? 'A'
                            : 'B',
                      ),
                    ),
                  ),
                ),
              if (ride.isMapPicking)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: screenHeight * 0.22,
                  child: _MapPickPanel(
                    hint: ride.mapPickTarget != null
                        ? l10n.mapPickHint(ride.mapPickTarget!)
                        : '',
                    subHint: l10n.mapPickTapOrMove,
                    onConfirm: () {
                      ride.applyMapLocation(
                        _mapController.camera.center,
                        l10n,
                      );
                    },
                    onCancel: ride.cancelMapPick,
                    confirmLabel: l10n.confirmPoint,
                    cancelLabel: l10n.cancel,
                  ),
                ),
              _OrderBottomSheet(
                onPickupTap: () => _openAddressSearch(isPickup: true),
                onDropoffTap: () => _openAddressSearch(isPickup: false),
                onSuggestionTap: (address) {
                  context.read<RideProvider>().setDropoff(address);
                },
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
    required this.pickupEtaLabel,
    this.onMapTap,
  });

  final MapController mapController;
  final RideProvider ride;
  final String pickupEtaLabel;
  final void Function(LatLng point)? onMapTap;

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

    if (ride.pickup != null && ride.status == RideStatus.idle) {
      markers.add(
        Marker(
          point: ride.pickup!.location,
          width: 170,
          height: 56,
          alignment: Alignment.bottomCenter,
          child: YandexPickupBubble(etaLabel: pickupEtaLabel),
        ),
      );
    }

    if (ride.showPickupMarker && ride.pickup != null && ride.dropoff != null) {
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
        onTap: onMapTap != null
            ? (_, point) => onMapTap!(point)
            : null,
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
                borderColor: Colors.white,
                borderStrokeWidth: 2,
              ),
            ],
          ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}

class _OrderBottomSheet extends StatelessWidget {
  const _OrderBottomSheet({
    required this.onPickupTap,
    required this.onDropoffTap,
    required this.onSuggestionTap,
  });

  final VoidCallback onPickupTap;
  final VoidCallback onDropoffTap;
  final void Function(Address address) onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, ride, _) {
        return DraggableScrollableSheet(
          initialChildSize: ride.isMapPicking ? 0.18 : _sheetSize(ride.status),
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
        return 0.38;
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
          onSuggestionTap: onSuggestionTap,
          onPickupMapPick: () =>
              context.read<RideProvider>().startMapPick(MapPickTarget.pickup),
          onDropoffMapPick: () =>
              context.read<RideProvider>().startMapPick(MapPickTarget.dropoff),
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
    required this.onSuggestionTap,
    required this.onPickupMapPick,
    required this.onDropoffMapPick,
  });

  final VoidCallback onPickupTap;
  final VoidCallback onDropoffTap;
  final void Function(Address address) onSuggestionTap;
  final VoidCallback onPickupMapPick;
  final VoidCallback onDropoffMapPick;

  IconData _iconForAddress(Address address) {
    final title = address.title.toLowerCase();
    if (title.contains('аэропорт') ||
        title.contains('aeroport') ||
        title.contains('airport')) {
      return Icons.flight;
    }
    return Icons.place;
  }

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();
    final l10n = AppLocalizations.of(context);
    final suggestions = ride.searchAddresses('').take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const YandexGoLogo(size: 36),
            const SizedBox(width: 10),
            Text(
              l10n.taxi,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        YandexDestinationBar(
          hint: l10n.whereGoing,
          value: ride.dropoff?.title,
          onTap: onDropoffTap,
        ),
        if (ride.dropoff == null) ...[
          const SizedBox(height: 8),
          ...suggestions.map(
            (address) => YandexSuggestionTile(
              icon: _iconForAddress(address),
              title: address.title,
              subtitle: address.subtitle,
              onTap: () => onSuggestionTap(address),
            ),
          ),
        ],
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

class _MapPickPanel extends StatelessWidget {
  const _MapPickPanel({
    required this.hint,
    required this.subHint,
    required this.onConfirm,
    required this.onCancel,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String hint;
  final String subHint;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: AppColors.primary.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(20),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              hint,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subHint,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(cancelLabel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: confirmLabel,
                    onPressed: onConfirm,
                    icon: Icons.check,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
