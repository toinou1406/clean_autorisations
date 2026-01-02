
import 'package:clean/permission_handler_service.dart';
import 'package:flutter/material.dart';
import 'package:clean/l10n/app_localizations.dart';
import 'package:clean/aurora_widgets.dart';

class PermissionScreen extends StatelessWidget {
  final AppPermissionStatus initialStatus;
  final PermissionHandlerService permissionService;
  final void Function(Locale) onLocaleChanged;

  const PermissionScreen({
    super.key,
    required this.initialStatus,
    required this.permissionService,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final content = _buildContentForStatus(context, initialStatus, l10n, theme);

    return Scaffold(
      body: NoiseBox(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                PulsingIcon(
                  icon: content['icon'],
                  color: theme.colorScheme.primary,
                  size: 60,
                ),
                const SizedBox(height: 32),
                Text(
                  content['title'],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  content['description'],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withAlpha(204),
                    height: 1.6,
                  ),
                ),
                const Spacer(flex: 3),
                ElevatedButton(
                  onPressed: content['action'],
                  style: theme.elevatedButtonTheme.style?.copyWith(
                    padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 20)),
                  ),
                  child: Text(content['buttonText']),
                ),
                const SizedBox(height: 40),
                _buildLanguageSelector(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    // Extracted for clarity
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFlagButton(context, '🇬🇧', const Locale('en')),
        _buildFlagButton(context, '🇫🇷', const Locale('fr')),
        _buildFlagButton(context, '🇪🇸', const Locale('es')),
        _buildFlagButton(context, '🇨🇳', const Locale('zh')),
        _buildFlagButton(context, '🇺🇦', const Locale('uk')),
      ],
    );
  }

  Widget _buildFlagButton(BuildContext context, String flag, Locale locale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: () => onLocaleChanged(locale),
        style: TextButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(12),
          backgroundColor: AppLocalizations.of(context).localeName == locale.languageCode
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Text(
          flag,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }

  Map<String, dynamic> _buildContentForStatus(
    BuildContext context,
    AppPermissionStatus status,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    switch (status) {
      case AppPermissionStatus.limited:
        return {
          'icon': Icons.error_outline_rounded,
          'title': l10n.permissionLimitedTitle,
          'description': l10n.permissionLimitedDescription,
          'buttonText': l10n.openSettings,
          'action': () => permissionService.openAppSettings(),
        };
      case AppPermissionStatus.permanentlyDenied:
        return {
          'icon': Icons.settings_rounded,
          'title': l10n.permissionPermanentlyDeniedTitle,
          'description': l10n.permissionPermanentlyDeniedDescription,
          'buttonText': l10n.openSettings,
          'action': () => permissionService.openAppSettings(),
        };
      case AppPermissionStatus.denied:
      default:
        return {
          'icon': Icons.shield_outlined,
          'title': l10n.permissionTitle,
          'description': l10n.permissionDescription,
          'buttonText': l10n.grantPermission,
          'action': () => permissionService.requestPermission(),
        };
    }
  }
}
