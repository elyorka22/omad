import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.textPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

class AddressRow extends StatelessWidget {
  const AddressRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class RideClassCard extends StatelessWidget {
  const RideClassCard({
    super.key,
    required this.rideClass,
    required this.title,
    required this.priceLabel,
    required this.etaLabel,
    required this.isSelected,
    required this.onTap,
  });

  final RideClass rideClass;
  final String title;
  final String priceLabel;
  final String etaLabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 110,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.25) : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rideClass.icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              etaLabel,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              priceLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverCard extends StatelessWidget {
  const DriverCard({
    super.key,
    required this.driver,
    required this.etaText,
    required this.arrivalLabel,
  });

  final Driver driver;
  final String etaText;
  final String arrivalLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(driver.photoEmoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${driver.carModel} · ${driver.carNumber}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      driver.rating.toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                etaText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                arrivalLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MapMarkerWidget extends StatelessWidget {
  const MapMarkerWidget({
    super.key,
    required this.color,
    required this.label,
    this.isDriver = false,
  });

  final Color color;
  final String label;
  final bool isDriver;

  @override
  Widget build(BuildContext context) {
    if (isDriver) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.driverMarker,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.local_taxi, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.driverMarker,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Icon(Icons.location_on, color: color, size: 32),
      ],
    );
  }
}

class UserLocationMarker extends StatefulWidget {
  const UserLocationMarker({super.key});

  @override
  State<UserLocationMarker> createState() => _UserLocationMarkerState();
}

class _UserLocationMarkerState extends State<UserLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + _pulseController.value * 0.8;
          final opacity = 0.5 * (1 - _pulseController.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.userLocation.withValues(alpha: opacity),
                  ),
                ),
              ),
              child!,
            ],
          );
        },
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.userLocation,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.userLocation.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MapFloatingButton extends StatelessWidget {
  const MapFloatingButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppColors.primary : AppColors.surface,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip ?? '',
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(
              icon,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
