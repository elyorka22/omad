import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/ride_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradientVertical,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('👤', style: TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.user,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.isUzbek ? '+998 90 123 45 67' : '+7 (999) 123-45-67',
                      style: TextStyle(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.language,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _LanguageOption(
                  label: l10n.russian,
                  code: 'RU',
                  isSelected: localeProvider.locale.languageCode == 'ru',
                  onTap: () {
                    localeProvider.setRussian();
                    ride.updateLanguage('ru', AppLocalizations('ru'));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LanguageOption(
                  label: l10n.uzbek,
                  code: 'UZ',
                  isSelected: localeProvider.locale.languageCode == 'uz',
                  onTap: () {
                    localeProvider.setUzbek();
                    ride.updateLanguage('uz', AppLocalizations('uz'));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.rideHistory,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (ride.history.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  l10n.noRides,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...ride.history.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    '${item.from} → ${item.to}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${l10n.rideClassName(item.rideClass)} · ${dateFormat.format(item.date)}',
                    ),
                  ),
                  trailing: Text(
                    l10n.formatPrice(item.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 24),
          _MenuTile(icon: Icons.payment, title: l10n.payment, onTap: () {}),
          _MenuTile(icon: Icons.favorite_border, title: l10n.favorites, onTap: () {}),
          _MenuTile(icon: Icons.support_agent, title: l10n.support, onTap: () {}),
          _MenuTile(icon: Icons.settings, title: l10n.settings, onTap: () {}),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.surfaceMuted
          : AppColors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
            gradient: isSelected ? AppColors.cardGradient : null,
          ),
          child: Column(
            children: [
              Text(
                code,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? AppColors.accent : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textPrimary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
