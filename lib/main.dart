
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Custom Widgets
import 'aurora_circular_indicator.dart';
import 'full_screen_image_view.dart';
import 'permission_screen.dart';
import 'photo_analyzer.dart';
import 'photo_cleaner_service.dart';
import 'saved_space_indicator.dart';
import 'sorting_indicator_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool permissionGranted = prefs.getBool('permission_granted') ?? false;

  runApp(MyApp(
    initialRoute: permissionGranted ? AppRoutes.home : AppRoutes.permission,
  ));
}

class AppRoutes {
  static const String home = '/';
  static const String permission = '/permission';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    const Color darkCharcoal = Color(0xFF1A1A1A);
    const Color offWhite = Color(0xFFEAEAEA);
    const Color neonGreen = Color(0xFF39FF14);

    final TextTheme appTextTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: offWhite),
      titleMedium: GoogleFonts.inter(fontSize: 18, color: offWhite.withOpacity(0.8)),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: offWhite.withOpacity(0.7)),
      labelLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: darkCharcoal),
    );

    final ThemeData theme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: darkCharcoal,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        onPrimary: darkCharcoal,
        secondary: offWhite,
        surface: Color(0xFF2C2C2C),
        onSurface: offWhite,
        error: Colors.redAccent,
        primaryContainer: neonGreen, // Using primaryContainer for the neon color
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: offWhite),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(darkCharcoal),
          backgroundColor: WidgetStateProperty.all(Colors.white),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
          textStyle: WidgetStateProperty.all(GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(neonGreen),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(Colors.white),
          side: WidgetStateProperty.all(BorderSide(color: Colors.white.withOpacity(0.5))),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
          textStyle: WidgetStateProperty.all(GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          shadowColor: WidgetStateProperty.all(neonGreen),
        ),
      ),
    );

    return MaterialApp(
      title: 'FastClean',
      theme: theme,
      initialRoute: initialRoute,
      routes: {
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.permission: (context) => PermissionScreen(
          onPermissionGranted: () {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          },
        ),
      },
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
  List<PhotoResult> _selectedPhotos = [];
  final Set<String> _ignoredPhotos = {};
  bool _isLoading = false;
  bool _isDeleting = false; 
  bool _hasScanned = false;
  String _sortingMessage = "Sorting...";
  Timer? _messageTimer;
  bool _isInitialized = false;

  final List<String> _sortingMessages = [
    "Analyzing photo metadata...",
    "Detecting blurry images...",
    "Searching for bad screenshots...",
    "Checking for duplicates...",
    "Calculating photo scores...",
    "Compiling results...",
    "Ranking photos by 'badness'...",
    "Finalizing the photo selection...",
  ];

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
      setState(() {
        _isInitialized = true;
      });
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
    final photoIds = _selectedPhotos.map((p) => p.asset.id).toList();
    await prefs.setStringList('selected_photo_ids', photoIds);
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
      List<PhotoResult> restoredPhotos = [];
      for (final id in photoIds) {
        try {
          final asset = await AssetEntity.fromId(id);
          if (asset != null) {
            restoredPhotos.add(PhotoResult(asset, PhotoAnalysisResult.dummy()));
          }
        } catch (e) {
          // Asset might have been deleted.
        }
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
    final lastSavedMonth = prefs.getInt('lastSavedMonth');
    final currentMonth = DateTime.now().month;
    if (lastSavedMonth != currentMonth) {
      setState(() => _spaceSaved = 0.0);
      await prefs.setDouble('spaceSaved', 0.0);
      await prefs.setInt('lastSavedMonth', currentMonth);
    }
  }

  Future<void> _loadSavedSpace() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _spaceSaved = prefs.getDouble('spaceSaved') ?? 0.0;
    });
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
    if (mounted) {
      setState(() => _storageInfo = info);
    }
  }
  
  Future<void> _sortPhotos({bool rescan = false}) async {
    setState(() {
      _isLoading = true;
      _sortingMessage = _sortingMessages[Random().nextInt(_sortingMessages.length)];
    });

    _messageTimer?.cancel();
    _messageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isLoading) {
        timer.cancel();
        return;
      }
      setState(() {
        _sortingMessage = _sortingMessages[Random().nextInt(_sortingMessages.length)];
      });
    });
    
    try {
      if (rescan) _service.reset();
      if (!_hasScanned || rescan) {
        await _service.scanPhotos();
        if (mounted) setState(() => _hasScanned = true);
      }
      
      final photos = await _service.selectPhotosToDelete(excludedIds: _ignoredPhotos.toList());
      
      if (mounted) {
        if (photos.isEmpty && _hasScanned) {
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No more deletable photos found!')),
            );
        }
        setState(() {
          _selectedPhotos = photos;
          _isLoading = false;
        });
        _preCachePhotoFiles(photos);
      }
    } catch (e, s) {
        if (mounted) {
            setState(() => _isLoading = false);
            developer.log('Error during photo sorting', name: 'photo_cleaner.error', error: e, stackTrace: s);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('An error occurred: ${e.toString()}')),
            );
        }
    }
  }

  void _preCachePhotoFiles(List<PhotoResult> photos) {
    Future(() async {
      for (final photo in photos) {
        try {
          await photo.asset.file;
        } catch (e) { /* Ignore errors */ }
      }
    });
  }
  
  Future<void> _deletePhotos() async {
    HapticFeedback.heavyImpact();
    setState(() => _isDeleting = true); 
    
    try {
      final photosToDelete = _selectedPhotos.where((p) => !_ignoredPhotos.contains(p.asset.id)).toList();
      final Map<String, int> sizeMap = {};
      for (final photo in photosToDelete) {
        final file = await photo.asset.file;
        sizeMap[photo.asset.id] = await file?.length() ?? 0;
      }

      final deletedIds = await _service.deletePhotos(photosToDelete);
      if (deletedIds.isEmpty && photosToDelete.isNotEmpty) {
        if (mounted) setState(() => _isDeleting = false);
        return;
      }

      int totalBytesDeleted = deletedIds.fold(0, (sum, id) => sum + (sizeMap[id] ?? 0));
      
      if (mounted) {
        setState(() {
          _selectedPhotos = [];
          _ignoredPhotos.clear();
          _isDeleting = false;
          _spaceSaved += totalBytesDeleted;
        });
        _saveSavedSpace();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted ${deletedIds.length} photos and saved ${_formatBytes(totalBytesDeleted.toDouble())}')),
        );
      }
      await _loadStorageInfo();
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting photos: $e')),
        );
      }
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
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('FastClean', style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _buildMainContent(),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_selectedPhotos.isNotEmpty) {
      return GridView.builder(
        key: const ValueKey('grid'),
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _selectedPhotos.length,
        itemBuilder: (context, index) {
          final photo = _selectedPhotos[index];
          return PhotoCard(
            key: ValueKey(photo.asset.id),
            photo: photo,
            isIgnored: _ignoredPhotos.contains(photo.asset.id),
            onToggleKeep: () => _toggleIgnoredPhoto(photo.asset.id),
            onOpenFullScreen: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImageView(
                    photos: _selectedPhotos,
                    initialIndex: index,
                    ignoredPhotos: _ignoredPhotos,
                    onToggleKeep: _toggleIgnoredPhoto,
                  ),
                ),
              );
            },
          );
        },
      );
    }
    
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primaryContainer));
    }

    return EmptyState(
      key: const ValueKey('empty'),
      storageInfo: _storageInfo,
      spaceSaved: _spaceSaved,
      formattedSpaceSaved: _formatBytes(_spaceSaved),
    );
  }

  Widget _buildBottomBar() {
    if (_isDeleting) {
      return const SizedBox.shrink(); 
    }

    int photosToDeleteCount = _selectedPhotos.length - _ignoredPhotos.length;

    return Container(
      padding: const EdgeInsets.all(20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading
          ? SortingIndicatorBar(message: _sortingMessage, neonColor: Theme.of(context).colorScheme.primaryContainer)
          : _selectedPhotos.isNotEmpty
            ? Row(
                children: [
                  Expanded(
                    child: ActionButton(
                      label: 'Re-sort',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _sortPhotos();
                      },
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  photosToDeleteCount > 0
                    ? Expanded(
                        child: ActionButton(
                          label: 'Delete ($photosToDeleteCount)',
                          onPressed: _deletePhotos,
                          isPrimary: true,
                        ),
                      )
                    : Expanded(
                        child: ActionButton(
                          label: 'Pass',
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedPhotos = [];
                              _ignoredPhotos.clear();
                            });
                          },
                          isPrimary: false,
                        ),
                      ),
                ],
              )
            : ActionButton(
                label: 'Analyze Photos',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _sortPhotos(rescan: true);
                },
                isPrimary: true,
              ),
      ),
    );
  }
}

class PhotoCard extends StatefulWidget {
  final PhotoResult photo;
  final bool isIgnored;
  final VoidCallback onToggleKeep;
  final VoidCallback onOpenFullScreen;

  const PhotoCard({
    super.key,
    required this.photo,
    required this.isIgnored,
    required this.onToggleKeep,
    required this.onOpenFullScreen,
  });

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
    final data = await widget.photo.asset.thumbnailDataWithSize(const ThumbnailSize(200, 200));
    if (mounted) {
      setState(() => _thumbnailData = data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = Theme.of(context).colorScheme.primaryContainer;

    return GestureDetector(
      onTap: widget.onOpenFullScreen,
      onDoubleTap: widget.onToggleKeep,
      child: Hero(
        tag: widget.photo.asset.id,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isIgnored ? neonColor : Colors.transparent,
              width: 3,
            ),
            boxShadow: widget.isIgnored ? [
              BoxShadow(
                color: neonColor.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 1,
              )
            ] : [],
          ),
          clipBehavior: Clip.antiAlias,
          child: _thumbnailData != null
              ? Image.memory(_thumbnailData!, fit: BoxFit.cover)
              : Container(color: Colors.grey[850]),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const ActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    final neonColor = Theme.of(context).colorScheme.primaryContainer;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: neonColor.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      height: 60,
      width: double.infinity,
      child: isPrimary
        ? ElevatedButton(
            onPressed: onPressed,
            child: Text(label),
          )
        : OutlinedButton(
            onPressed: onPressed,
            child: Text(label),
          ),
    );
  }
}

class EmptyState extends StatefulWidget {
  final StorageInfo? storageInfo;
  final double spaceSaved;
  final String formattedSpaceSaved;

  const EmptyState({
    super.key,
    required this.storageInfo,
    required this.spaceSaved,
    required this.formattedSpaceSaved,
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.storageInfo != null)
            AuroraCircularIndicator(storageInfo: widget.storageInfo!)
          else
            const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 40),
          SavedSpaceIndicator(
            spaceSaved: widget.spaceSaved,
            formattedSpaceSaved: widget.formattedSpaceSaved,
          ),
        ],
      ),
    );
  }
}
