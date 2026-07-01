import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/ride_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/yandex_ui.dart';

class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({
    super.key,
    required this.isPickup,
  });

  final bool isPickup;

  @override
  State<AddressSearchScreen> createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  final _controller = TextEditingController();
  List<Address> _results = [];

  @override
  void initState() {
    super.initState();
    final ride = context.read<RideProvider>();
    _results = ride.searchAddresses('');
    if (!widget.isPickup) {
      _controller.addListener(_onSearchChanged);
    }
  }

  void _onSearchChanged() {
    final results =
        context.read<RideProvider>().searchAddresses(_controller.text);
    setState(() => _results = results);
  }

  void _selectAddress(Address address) {
    final ride = context.read<RideProvider>();
    if (widget.isPickup) {
      ride.setPickup(address);
    } else {
      ride.setDropoff(address);
    }
    Navigator.pop(context);
  }

  void _openMapPick() {
    final ride = context.read<RideProvider>();
    Navigator.pop(context);
    ride.startMapPick(
      widget.isPickup ? MapPickTarget.pickup : MapPickTarget.dropoff,
    );
  }

  IconData _iconForAddress(Address address) {
    final title = address.title.toLowerCase();
    if (title.contains('аэропорт') ||
        title.contains('aeroport') ||
        title.contains('airport')) {
      return Icons.flight;
    }
    if (title.contains('метро') || title.contains('metro')) {
      return Icons.subway;
    }
    return Icons.place;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            YandexAddressCard(
              pickupLabel: l10n.pickupPoint,
              pickupAddress: ride.pickup?.title ?? l10n.specifyPickup,
              destinationLabel: l10n.destinationPoint,
              destinationHint: l10n.whereWillYouGo,
              destinationAddress: ride.dropoff?.title,
              mapButtonLabel: l10n.mapButton,
              focusDestination: !widget.isPickup,
              onPickupTap: () {
                if (!widget.isPickup) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AddressSearchScreen(isPickup: true),
                    ),
                  );
                }
              },
              onDestinationTap: () {
                if (widget.isPickup) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AddressSearchScreen(isPickup: false),
                    ),
                  );
                }
              },
              onMapTap: _openMapPick,
            ),
            if (!widget.isPickup)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.enterAddress,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                color: AppColors.surface,
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 74,
                  ),
                  itemBuilder: (context, index) {
                    final address = _results[index];
                    return YandexSuggestionTile(
                      icon: _iconForAddress(address),
                      title: address.title,
                      subtitle: address.subtitle,
                      onTap: () => _selectAddress(address),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
