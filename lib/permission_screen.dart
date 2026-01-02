
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
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
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
                const SizedBox(height: 20),
              ],
            ),
          ),
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
