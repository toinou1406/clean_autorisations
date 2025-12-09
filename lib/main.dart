
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:fastclean/aurora_circular_indicator.dart';
import 'package:fastclean/saved_space_indicator.dart';
import 'package:fastclean/sorting_indicator_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

// Aurora & Custom Widgets
import 'aurora_widgets.dart';

import 'full_screen_image_view.dart';
import 'permission_screen.dart';
import 'language_settings_screen.dart';
import 'photo_analyzer.dart';
import 'photo_cleaner_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool permissionGranted = prefs.getBool('permission_granted') ?? false;
  final String? languageCode = prefs.getString('language_code');

  runApp(MyApp(
    initialRoute: permissionGranted ? AppRoutes.home : AppRoutes.permission,
    locale: languageCode != null ? Locale(languageCode) : null,
  ));
}

class AppRoutes {
  static const String home = '/';
  static const String permission = '/permission';
  static const String settings = '/settings';
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialRoute, this.locale});
  final String initialRoute;
  final Locale? locale;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.locale ?? AppLocalizations.supportedLocales.first;
  }

  void changeLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

 @override
Widget build(BuildContext context) {
  const Color primarySeedColor = Color(0xFF2E7D32); // Deep Green from Logo

  final TextTheme appTextTheme = GoogleFonts.nunitoTextTheme(
    ThemeData.dark().textTheme,
  ).copyWith(
    displayLarge: GoogleFonts.nunito(fontSize: 52, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2),
    displayMedium: GoogleFonts.nunito(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
    displaySmall: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
    headlineMedium: GoogleFonts.nunito(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white.withAlpha(242)), // ~0.95 opacity
    headlineSmall: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white.withAlpha(229)), // ~0.9 opacity
    titleLarge: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white.withAlpha(217)), // ~0.85 opacity
    titleMedium: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white.withAlpha(204)), // ~0.8 opacity
    bodyLarge: GoogleFonts.nunito(fontSize: 16, color: Colors.white.withAlpha(191), height: 1.5), // ~0.75 opacity
    bodyMedium: GoogleFonts.nunito(fontSize: 14, color: Colors.white.withAlpha(179), height: 1.5), // ~0.7 opacity
    labelLarge: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
  );

  final elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: primarySeedColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      textStyle: appTextTheme.labelLarge,
      elevation: 2,
      shadowColor: primarySeedColor.withAlpha(102), // ~0.4 opacity
    ),
  );

  final cardTheme = CardTheme(
    elevation: 0,
    color: Colors.white.withAlpha(13), // ~0.05 opacity
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );

  final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.light,
      primary: primarySeedColor,
      secondary: const Color(0xFF4CAF50),
      surface: const Color(0xFFF5F5F5),
      background: const Color(0xFFFFFFFF),
    ),
    textTheme: appTextTheme.apply(bodyColor: const Color(0xFF121212), displayColor: const Color(0xFF121212)),
    scaffoldBackgroundColor: const Color(0xFFF9F9F9),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: appTextTheme.headlineSmall?.apply(color: const Color(0xFF121212)),
      iconTheme: const IconThemeData(color: Color(0xFF121212)),
    ),
    elevatedButtonTheme: elevatedButtonTheme,
    cardTheme: cardTheme,
    dividerColor: Colors.black.withAlpha(26), // ~0.1 opacity
  );

  final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.dark,
      primary: primarySeedColor,
      secondary: const Color(0xFF66BB6A),
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
    ),
    textTheme: appTextTheme,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: appTextTheme.headlineSmall,
      iconTheme: IconThemeData(color: Colors.white.withAlpha(217)), // ~0.85 opacity
    ),
    elevatedButtonTheme: elevatedButtonTheme,
    cardTheme: cardTheme,
    dividerColor: Colors.white.withAlpha(26), // ~0.1 opacity
  );

  return MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'FastClean',
    theme: lightTheme,
    darkTheme: darkTheme,
    themeMode: ThemeMode.dark,
    locale: _locale,
    debugShowCheckedModeBanner: false,
    initialRoute: widget.initialRoute,
    routes: {
      AppRoutes.home: (context) => const HomeScreen(),
      AppRoutes.permission: (context) => PermissionScreen(
        onPermissionGranted: () {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        },
        onLocaleChanged: changeLocale,
      ),
      AppRoutes.settings: (context) => LanguageSettingsScreen(onLocaleChanged: changeLocale),
    },
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final PhotoCleanerService _service = PhotoCleanerService();

  StorageInfo? _storageInfo;
  double _spaceSaved = 0.0;
  List<PhotoAnalysisResult> _selectedPhotos = [];
  final Set<String> _ignoredPhotos = {};
  bool _isLoading = false;
  bool _isDeleting = false;
  bool _hasScanned = false;
  String _sortingMessage = "";
  Timer? _messageTimer;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadStorageInfo();
    await _resetMonthlySavedSpace();
    await _loadSavedSpace();
    await _restoreState();
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _saveState();
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selected_photo_ids', _selectedPhotos.map((p) => p.asset.id).toList());
    await prefs.setStringList('ignored_photo_ids', _ignoredPhotos.toList());
    await prefs.setBool('has_scanned', _hasScanned);
  }

  Future<void> _restoreState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('selected_photo_ids')) return;

    final photoIds = prefs.getStringList('selected_photo_ids') ?? [];
    final ignoredIds = prefs.getStringList('ignored_photo_ids') ?? [];
    final hasScanned = prefs.getBool('has_scanned') ?? false;

    if (photoIds.isNotEmpty) {
      List<PhotoAnalysisResult> restoredPhotos = [];
      for (final id in photoIds) {
        try {
          final asset = await AssetEntity.fromId(id);
          if (asset != null) {
            // The analysis result is not saved, so we create an empty one
            restoredPhotos.add(PhotoAnalysisResult(asset, PhotoAnalysisResult.empty().blurriness, PhotoAnalysisResult.empty().isScreenshot, PhotoAnalysisResult.empty().duplicateOf));

          }
        } catch (e) { /* Asset might have been deleted. */ }
      }

      if (mounted) {
        setState(() {
          _selectedPhotos = restoredPhotos;
          _ignoredPhotos.addAll(ignoredIds);
          _hasScanned = hasScanned;
        });
      }
    }
  }

  Future<void> _resetMonthlySavedSpace() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('lastSavedMonth') != DateTime.now().month) {
      setState(() => _spaceSaved = 0.0);
      await prefs.setDouble('spaceSaved', 0.0);
      await prefs.setInt('lastSavedMonth', DateTime.now().month);
    }
  }

  Future<void> _loadSavedSpace() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _spaceSaved = prefs.getDouble('spaceSaved') ?? 0.0);
  }

  Future<void> _saveSavedSpace() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('spaceSaved', _spaceSaved);
    await prefs.setInt('lastSavedMonth', DateTime.now().month);
  }

  String _formatBytes(double bytes, [int decimals = 2]) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  Future<void> _loadStorageInfo() async {
    final info = await _service.getStorageInfo();
    if (mounted) setState(() => _storageInfo = info);
  }

  Future<void> _sortPhotos({bool rescan = false}) async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    final sortingMessages = [
      l10n.sortingMessageAnalyzing,
      l10n.sortingMessageBlurry,
      l10n.sortingMessageScreenshots,
      l10n.sortingMessageDuplicates,
      l10n.sortingMessageScores,
      l10n.sortingMessageCompiling,
      l10n.sortingMessageRanking,
      l10n.sortingMessageFinalizing,
    ];

    setState(() {
      _isLoading = true;
      _sortingMessage = sortingMessages.first;
    });

    _messageTimer?.cancel();
    int msgIndex = 0;
    _messageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isLoading) { timer.cancel(); return; }
      setState(() => _sortingMessage = sortingMessages[++msgIndex % sortingMessages.length]);
    });

    try {
      if (rescan) _service.reset();
      await _service.scanPhotos(permissionErrorMessage: l10n.photoAccessRequired);
      if (mounted) setState(() => _hasScanned = true);

      final photos = await _service.selectPhotosToDelete(excludedIds: _ignoredPhotos.toList());

      if (mounted) {
        if (photos.isEmpty && _hasScanned) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.noMorePhotos)),
          );
        }
        setState(() => _selectedPhotos = photos);
        _preCachePhotoFiles(photos);
      }
    } catch (e, s) {
      developer.log('Error during photo sorting', name: 'photo_cleaner.error', error: e, stackTrace: s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorOccurred(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _messageTimer?.cancel();
    }
  }

  void _preCachePhotoFiles(List<PhotoAnalysisResult> photos) {
    for (final photo in photos) {
      photo.asset.file; // no need to await
    }
  }

  Future<void> _deletePhotos() async {
    HapticFeedback.heavyImpact();
    setState(() => _isDeleting = true);

    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    try {
      final photosToDelete = _selectedPhotos.where((p) => !_ignoredPhotos.contains(p.asset.id)).toList();
      final Map<String, int> sizeMap = {};
      await Future.forEach(photosToDelete, (photo) async {
        final file = await photo.asset.file;
        sizeMap[photo.asset.id] = await file?.length() ?? 0;
      });

      final deletedIds = await _service.deletePhotos(photosToDelete);
      if (deletedIds.isEmpty && photosToDelete.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.couldNotDelete)));
        setState(() => _isDeleting = false);
        return;
      }

      int totalBytesDeleted = deletedIds.fold(0, (sum, id) => sum + (sizeMap[id] ?? 0));

      if (mounted) {
        setState(() {
          _selectedPhotos = [];
          _ignoredPhotos.clear();
          _spaceSaved += totalBytesDeleted;
        });
        _saveSavedSpace();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.photosDeleted(deletedIds.length, _formatBytes(totalBytesDeleted.toDouble())))),
        );
      }
      await _loadStorageInfo();
    } catch (e,s) {
      developer.log('Error deleting photos', name: 'photo_cleaner.error', error: e, stackTrace: s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorDeleting(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _toggleIgnoredPhoto(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_ignoredPhotos.contains(id)) {
        _ignoredPhotos.remove(id);
      } else {
        _ignoredPhotos.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (!_isInitialized || l10n == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeScreenTitle, key: const Key('homeScreenTitle')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: NoiseBox(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                  child: _buildMainContent(),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_selectedPhotos.isNotEmpty) {
      return GridView.builder(
        key: const ValueKey('grid'),
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
        itemCount: _selectedPhotos.length,
        itemBuilder: (context, index) {
          final photo = _selectedPhotos[index];
          return PhotoCard(
            key: ValueKey(photo.asset.id),
            photo: photo,
            isIgnored: _ignoredPhotos.contains(photo.asset.id),
            onToggleKeep: () => _toggleIgnoredPhoto(photo.asset.id),
            onOpenFullScreen: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => FullScreenImageView(
                  photos: _selectedPhotos,
                  initialIndex: index,
                  ignoredPhotos: _ignoredPhotos,
                  onToggleKeep: _toggleIgnoredPhoto,
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            ),
          );
        },
      );
    }

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary)));
    }

    final l10n = AppLocalizations.of(context);
    return EmptyState(
      key: const ValueKey('empty'),
      storageInfo: _storageInfo,
      spaceSaved: _spaceSaved,
      formattedSpaceSaved: _formatBytes(_spaceSaved),
      totalSpaceSavedText: l10n?.totalSpaceSaved ?? 'Total Space Saved',
    );
  }

  Widget _buildBottomBar() {
    if (_isDeleting) return const SizedBox.shrink();

    int photosToDeleteCount = _selectedPhotos.length - _ignoredPhotos.length;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: _isLoading
            ? SortingProgressIndicator(message: _sortingMessage)
            : _selectedPhotos.isNotEmpty
                ? Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n.reSort),
                          onPressed: () => _sortPhotos(),
                          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurface.withAlpha(179)), // ~0.7 opacity
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          icon: Icon(photosToDeleteCount > 0 ? Icons.delete_outline_rounded : Icons.check_rounded),
                          label: Text(photosToDeleteCount > 0 ? l10n.delete(photosToDeleteCount) : l10n.pass),
                          onPressed: photosToDeleteCount > 0
                              ? _deletePhotos
                              : () => setState(() {
                                    _selectedPhotos = [];
                                    _ignoredPhotos.clear();
                                  }),
                          style: photosToDeleteCount > 0
                              ? null
                              : ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                                ),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton.icon(
                    icon: const Icon(Icons.bolt_rounded),
                    label: Text(l10n.analyzePhotos),
                    onPressed: () => _sortPhotos(rescan: true),
                    key: const Key('analyzePhotosButton'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                  ),
      ),
    );
  }
}

class PhotoCard extends StatefulWidget {
  final PhotoAnalysisResult photo;
  final bool isIgnored;
  final VoidCallback onToggleKeep;
  final VoidCallback onOpenFullScreen;

  const PhotoCard({super.key, required this.photo, required this.isIgnored, required this.onToggleKeep, required this.onOpenFullScreen});

  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  Uint8List? _thumbnailData;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    final data = await widget.photo.asset.thumbnailDataWithSize(const ThumbnailSize(250, 250));
    if (mounted) setState(() => _thumbnailData = data);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: widget.onOpenFullScreen,
      onDoubleTap: widget.onToggleKeep,
      child: Hero(
        tag: widget.photo.asset.id,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_thumbnailData != null)
                Image.memory(_thumbnailData!, fit: BoxFit.cover)
              else
                Container(color: theme.colorScheme.surface),

              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: widget.isIgnored ? Colors.black.withAlpha(128) : Colors.transparent, // ~0.5 opacity
                  border: Border.all(
                    color: widget.isIgnored ? theme.colorScheme.primary : Colors.transparent,
                    width: 3.0,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
              ),

              AnimatedOpacity(
                opacity: widget.isIgnored ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, color: Colors.white.withAlpha(229), size: 32), // ~0.9 opacity
                      const SizedBox(height: 4),
                      if (l10n != null)
                        Text(
                          l10n.keep.toUpperCase(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withAlpha(229), // ~0.9 opacity
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatefulWidget {
  final StorageInfo? storageInfo;
  final double spaceSaved;
  final String formattedSpaceSaved;
  final String totalSpaceSavedText;

  const EmptyState({
    super.key,
    required this.storageInfo,
    required this.spaceSaved,
    required this.formattedSpaceSaved,
    required this.totalSpaceSavedText,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            StatCard(
              icon: Icons.cleaning_services_rounded,
              iconColor: theme.colorScheme.secondary,
              title: widget.totalSpaceSavedText,
              value: widget.formattedSpaceSaved,
            ),
            const SizedBox(height: 40),
            if (widget.storageInfo != null)
              StorageCircularIndicator(storageInfo: widget.storageInfo!)
            else
              CircularProgressIndicator(color: theme.colorScheme.primary),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
