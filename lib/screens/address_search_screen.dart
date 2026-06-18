import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/ride_provider.dart';
import '../theme/app_theme.dart';

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
    _results = context.read<RideProvider>().searchAddresses('');
    _controller.addListener(_onSearchChanged);
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPickup ? l10n.from : l10n.to),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: OutlinedButton.icon(
              onPressed: () {
                final ride = context.read<RideProvider>();
                Navigator.pop(context);
                ride.startMapPick(
                  widget.isPickup
                      ? MapPickTarget.pickup
                      : MapPickTarget.dropoff,
                );
              },
              icon: const Icon(Icons.map_outlined),
              label: Text(l10n.pickOnMap),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(
                  color: widget.isPickup
                      ? AppColors.pickupMarker
                      : AppColors.dropoffMarker,
                ),
                foregroundColor: widget.isPickup
                    ? AppColors.pickupMarker
                    : AppColors.dropoffMarker,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.enterAddress,
                prefixIcon: Icon(
                  widget.isPickup ? Icons.trip_origin : Icons.location_on,
                  color: widget.isPickup
                      ? AppColors.pickupMarker
                      : AppColors.dropoffMarker,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _results.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final address = _results[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.place, color: AppColors.textSecondary),
                  ),
                  title: Text(
                    address.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(address.subtitle),
                  onTap: () => _selectAddress(address),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
