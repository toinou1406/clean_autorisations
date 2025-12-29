
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:fastclean/l10n/app_localizations.dart';
import 'package:fastclean/aurora_widgets.dart'; // For PulsingIcon

class PermissionScreen extends StatefulWidget {
  final VoidCallback onPermissionGranted;
  final void Function(Locale) onLocaleChanged;

  const PermissionScreen({
    super.key,
    required this.onPermissionGranted,
    required this.onLocaleChanged,
  });

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  String? _currentLanguageCode;
  late AnimationController _fadeController;

  bool _showWarning = false;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  Future<void> _initializeScreen() async {
    if (mounted) {
      final languageCode = Localizations.localeOf(context).languageCode;
      setState(() {
        _currentLanguageCode = languageCode;
      });
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _isRequesting) {
      // User is returning from the settings screen or permission dialog
      _isRequesting = false;
      _checkPermission(showWarning: _showWarning);
    }
  }

  Future<void> _requestPermission() async {
    if (_isRequesting) return;

    setState(() {
      _isRequesting = true;
    });

    final result = await PhotoManager.requestPermissionExtend();
    
    if (result.isAuth) {
      _grantAccess();
    } else {
      // Permission not fully granted
      setState(() {
        _showWarning = true;
        _isRequesting = false;
      });
    }
  }

  Future<void> _checkPermission({bool showWarning = false}) async {
    final status = await PhotoManager.requestPermissionExtend();
    if (status.isAuth) {
      _grantAccess();
    } else {
      if (mounted && showWarning) {
        setState(() {
          _showWarning = true;
        });
      }
    }
  }


  void _grantAccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permission_granted', true);
    if (mounted) {
      widget.onPermissionGranted();
    }
  }

  void _changeLanguage(String languageCode) async {
    if (_currentLanguageCode == languageCode) return;

    final newLocale = Locale(languageCode);
    widget.onLocaleChanged(newLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    if (mounted) {
      setState(() {
        _currentLanguageCode = languageCode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: NoiseBox(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 1),
                  _buildLanguageSelector(theme, l10n),
                  const Spacer(flex: 1),
                  PulsingIcon(
                    icon: Icons.shield_outlined,
                    color: theme.colorScheme.primary,
                    size: 60,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.permissionTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.permissionDescription,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withAlpha(179), // ~0.7 opacity
                      height: 1.6,
                    ),
                  ),
                  if (_showWarning) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.permissionWarning,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const Spacer(flex: 3),
                  ElevatedButton(
                    onPressed: _requestPermission,
                    style: theme.elevatedButtonTheme.style?.copyWith(
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 20)),
                    ),
                    child: Text(l10n.grantPermission),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(ThemeData theme, AppLocalizations l10n) {
    if (_currentLanguageCode == null) return const SizedBox.shrink();

    return Column(
      children: [
        Text(
          l10n.chooseYourLanguage.toUpperCase(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(128), // ~0.5 opacity
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 16),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'en', label: Text('🇬🇧')),
            ButtonSegment(value: 'fr', label: Text('🇫🇷')),
            ButtonSegment(value: 'es', label: Text('🇪🇸')),
            ButtonSegment(value: 'zh', label: Text('🇨🇳')),
            ButtonSegment(value: 'uk', label: Text('🇺🇦')),
          ],
          selected: {_currentLanguageCode!},
          onSelectionChanged: (newSelection) {
            _changeLanguage(newSelection.first);
          },
          style: SegmentedButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            foregroundColor:
                theme.colorScheme.onSurface.withAlpha(179), // ~0.7 opacity
            selectedForegroundColor: theme.colorScheme.primary,
            selectedBackgroundColor:
                theme.colorScheme.primary.withAlpha(26), // ~0.1 opacity
            side: BorderSide(color: theme.dividerColor),
          ),
        ),
      ],
    );
  }
}
