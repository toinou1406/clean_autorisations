import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clean/l10n/app_localizations.dart';

class LanguageSettingsScreen extends StatefulWidget {
  final void Function(Locale) onLocaleChanged;

  const LanguageSettingsScreen({super.key, required this.onLocaleChanged});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String? _currentLanguageCode;

  @override
  void initState() {
    super.initState();
    // Wait for the context to be available before loading the locale.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentLanguage();
    });
  }

  Future<void> _loadCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentLanguageCode = prefs.getString('language_code') ?? Localizations.localeOf(context).languageCode;
      });
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

  if (_currentLanguageCode == null) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings), 
        centerTitle: true,
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: Text(l10n.settings),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: theme.dividerColor.withAlpha(26), // ~0.1 opacity
          height: 1.0,
        ),
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.chooseYourLanguage,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildLanguageOption(context: context, code: 'en', name: 'English', flag: '🇬🇧'),
                _buildLanguageOption(context: context, code: 'fr', name: 'Français', flag: '🇫🇷'),
                _buildLanguageOption(context: context, code: 'es', name: 'Español', flag: '🇪🇸'),
                _buildLanguageOption(context: context, code: 'zh', name: '中文', flag: '🇨🇳'),
                _buildLanguageOption(context: context, code: 'uk', name: 'Українська', flag: '🇺🇦'),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildLanguageOption({
    required BuildContext context,
    required String code,
    required String name,
    required String flag,
  }) {
    final theme = Theme.of(context);
    final isSelected = _currentLanguageCode == code;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: isSelected ? theme.colorScheme.primary.withAlpha(26) : theme.cardColor, // ~0.1 opacity
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _changeLanguage(code),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withAlpha(51), // ~0.2 opacity
                width: isSelected ? 2.0 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isSelected ? 1.0 : 0.0,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
