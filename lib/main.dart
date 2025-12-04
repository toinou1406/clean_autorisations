import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'dart:math';
import 'saved_space_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'photo_cleaner_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'permission_screen.dart';
import 'full_screen_image_view.dart';
import 'photo_analyzer.dart';

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
    const Color primarySeedColor = Colors.deepPurple;

    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
      labelLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
    );

    final ThemeData theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
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
            // When permission is granted, we replace the permission screen with the home screen.
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
    "Looking for overexposed photos...",
    "Finding underexposed photos...",
    "Identifying unneeded documents...",
    "Compiling results...",
    "Almost there...",
    "Ranking photos by 'badness'...",
    "Applying AI magic...",
    "Consulting the digital spirits...",
    "Sharpening the focus...",
    "Polishing the pixels...",
    "Running the AI hamster wheel...",
    "Herding cats... I mean, pixels...",
    "Optimizing the flux capacitor...",
    "Reticulating splines...",
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
            // We don't have the analysis result, so we create a dummy one.
            // This is a limitation of this simple state restoration.
            restoredPhotos.add(PhotoResult(asset, PhotoAnalysisResult(
              md5Hash: '',
              pHash: '',
              blurScore: 150, // a neutral score
              luminanceScore: 128, // a neutral score
              entropyScore: 6, // a neutral score
              edgeDensityScore: 0.05, // a neutral score
              isFromScreenshotAlbum: false,
            )));
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
      setState(() {
        _spaceSaved = 0.0;
      });
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
      setState(() {
        _storageInfo = info;
      });
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
      if (rescan) {
        _service.reset();
      }
      
      // The first scan can be slow, subsequent scans can be faster if we cache results.
      if (!_hasScanned || rescan) {
        await _service.scanPhotos();
        if (mounted) setState(() => _hasScanned = true);
      }
      
      final photos = await _service.selectPhotosToDelete(excludedIds: _ignoredPhotos.toList());
      
      if (mounted) {
        // Handle case where no photos are returned
        if (photos.isEmpty && _hasScanned) {
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No more deletable photos found! Try a new scan.')),
            );
        }
        setState(() {
          _selectedPhotos = photos;
          _isLoading = false;
        });
        // Pre-cache the full-resolution files in the background
        _preCachePhotoFiles(photos);
      }
    } catch (e, s) {
        if (mounted) {
            setState(() => _isLoading = false);
            developer.log(
                'Error during photo sorting',
                name: 'photo_cleaner.error',
                error: e,
                stackTrace: s,
            );
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('An error occurred: ${e.toString()}')),
            );
        }
    }
  }

  void _preCachePhotoFiles(List<PhotoResult> photos) {
    // This is a fire-and-forget method. We don't need to wait for it.
    Future(() async {
      for (final photo in photos) {
        try {
          // By calling .file, we are asking photo_manager to locate the file.
          // This often results in the OS caching the file path or even the
          // file content, making subsequent access much faster.
          await photo.asset.file;
        } catch (e) {
          // We ignore errors here as this is just an optimization.
          // If a file fails to cache, it will simply load normally when opened.
        }
      }
      developer.log(
        'Pre-caching for ${photos.length} photos complete.',
        name: 'photo_cleaner.cache',
      );
    });
  }
  
  Future<void> _showDeletionSummaryDialog(int count, int bytes) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Deletion Complete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('$count photos were deleted.'),
                const SizedBox(height: 10),
                Text('Space saved: ${_formatBytes(bytes.toDouble())}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePhotos() async {
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);
    
    try {
      final photosToDelete = _selectedPhotos
          .where((p) => !_ignoredPhotos.contains(p.asset.id))
          .toList();
      
      // Create a map of assetId to its size BEFORE deletion
      final Map<String, int> sizeMap = {};
      for (final photo in photosToDelete) {
        final file = await photo.asset.file;
        sizeMap[photo.asset.id] = await file?.length() ?? 0;
      }

      final deletedIds = await _service.deletePhotos(photosToDelete);
      
      if (deletedIds.isEmpty && photosToDelete.isNotEmpty) {
        // Deletion was likely cancelled by the user
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      // Calculate space saved from the map
      int totalBytesDeleted = 0;
      for (final id in deletedIds) {
        totalBytesDeleted += sizeMap[id] ?? 0;
      }
      
      if (mounted) {
        setState(() {
          _selectedPhotos = [];
          _ignoredPhotos.clear();
          _isLoading = false;
          _spaceSaved += totalBytesDeleted;
        });
        _saveSavedSpace();
      }
      
      await _loadStorageInfo();
      
      if (mounted && deletedIds.isNotEmpty) {
        await _showDeletionSummaryDialog(deletedIds.length, totalBytesDeleted);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final int photosToDeleteCount = _selectedPhotos.length - _ignoredPhotos.length;

    return Scaffold(
      body: Container(
        decoration: Platform.environment.containsKey('FLUTTER_TEST')
            ? null
            : const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/noise.png"),
                  fit: BoxFit.cover, 
                  opacity: 0.05,
                ),
              ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text('FastClean', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 36)),
                    const SizedBox(height: 20),
                    if (_storageInfo != null && _selectedPhotos.isEmpty)
                      StorageIndicator(storageInfo: _storageInfo!),
                    if (_selectedPhotos.isEmpty)
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          SavedSpaceIndicator(
                            spaceSaved: _spaceSaved,
                            formattedSpaceSaved: _formatBytes(_spaceSaved),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              
              if (_selectedPhotos.isEmpty)
                const Divider(),
              
              // PHOTO GRID
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _selectedPhotos.isEmpty && !_isLoading
                      ? const EmptyState(key: ValueKey('empty'))
                      : GridView.builder(
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
                        ),
                ),
              ),
              
              // ACTION BUTTONS
              Padding(
                padding: const EdgeInsets.all(20),
                child: _isLoading
                  ? _selectedPhotos.isEmpty
                    ? SortingProgressIndicator(message: _sortingMessage)
                    : const SizedBox.shrink()
                  : _selectedPhotos.isNotEmpty
                    // STATE: Photos are displayed for review
                    ? Row(
                        children: [
                          Expanded(
                            child: ActionButton(
                              label: 'Re-sort',
                              icon: Icons.refresh,
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _sortPhotos();
                              },
                              backgroundColor: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 16),
                          photosToDeleteCount > 0
                            ? Expanded(
                                child: ActionButton(
                                  label: 'Delete ($photosToDeleteCount)',
                                  icon: Icons.delete_forever,
                                  onPressed: _deletePhotos,
                                  backgroundColor: Colors.red[800],
                                ),
                              )
                            : Expanded(
                                child: ActionButton(
                                  label: 'Pass',
                                  icon: Icons.skip_next,
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      _selectedPhotos = [];
                                      _ignoredPhotos.clear();
                                    });
                                  },
                                  backgroundColor: Colors.blue[700],
                                ),
                              ),
                        ],
                      )
                    // STATE: Initial screen or after a deletion
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ActionButton(
                            label: 'Sort Photos to Delete',
                            icon: Icons.sort,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _sortPhotos(rescan: true);
                            },
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class StorageIndicator extends StatelessWidget {
  final StorageInfo storageInfo;
  const StorageIndicator({super.key, required this.storageInfo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text('Used Storage', style: Theme.of(context).textTheme.titleLarge)),
            Flexible(child: Text('${storageInfo.usedSpaceGB} / ${storageInfo.totalSpaceGB}', style: Theme.of(context).textTheme.titleLarge)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: storageInfo.usedPercentage / 100,
            minHeight: 12,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              storageInfo.usedPercentage > 80 ? Colors.red.shade400 : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
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

class _PhotoCardState extends State<PhotoCard> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  late AnimationController _wobbleController;
  late Animation<double> _wobbleAnimation;

  Uint8List? _thumbnailData;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();

    // Controller for the double-tap scale animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );

    // Controller for the wobble animation when a photo is kept
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _wobbleAnimation = Tween<double>(begin: -0.015, end: 0.015).animate(
      CurvedAnimation(parent: _wobbleController, curve: Curves.easeInOut),
    );

    if (widget.isIgnored) {
      _wobbleController.repeat(reverse: true);
    } else {
      _wobbleController.value = 0.5;
    }
  }

  Future<void> _loadThumbnail() async {
    final data = await widget.photo.asset.thumbnailDataWithSize(const ThumbnailSize(300, 300));
    if (mounted) {
      setState(() {
        _thumbnailData = data;
      });
    }
  }

  @override
  void didUpdateWidget(covariant PhotoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isIgnored != oldWidget.isIgnored) {
      if (widget.isIgnored) {
        // Play the bounce animation on state change
        _scaleController.forward().then((_) => _scaleController.reverse());
        // Start the wobble
        _wobbleController.repeat(reverse: true);
      } else {
        // Stop the wobble
        _wobbleController.stop();
        _wobbleController.animateTo(0.5, curve: Curves.easeOut); // Settle back to center
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _wobbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onOpenFullScreen,
      onDoubleTap: widget.onToggleKeep,
      onLongPress: widget.onToggleKeep,
      child: RotationTransition(
        turns: _wobbleAnimation,
        child: Hero(
          tag: widget.photo.asset.id,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Card(
              elevation: 8,
              shadowColor: Colors.black.withAlpha(128),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_thumbnailData != null)
                    Image.memory(_thumbnailData!, fit: BoxFit.cover)
                  else
                    const Center(child: CircularProgressIndicator()),
                  
                  if (widget.isIgnored)
                    Container(
                      color: Colors.green.withAlpha((255 * 0.5).round()),
                      child: Center(
                        child: Text(
                          'KEEP',
                          style: GoogleFonts.oswald(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              const Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  const ActionButton({super.key, required this.label, required this.icon, this.onPressed, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        minimumSize: const Size(double.infinity, 60),
        shadowColor: (backgroundColor ?? Theme.of(context).colorScheme.primary).withAlpha(128),
        elevation: 8,
      ),
    );
  }
}

class SortingProgressIndicator extends StatefulWidget {
  final String message;
  const SortingProgressIndicator({super.key, required this.message});

  @override
  State<SortingProgressIndicator> createState() => _SortingProgressIndicatorState();
}

class _SortingProgressIndicatorState extends State<SortingProgressIndicator> with TickerProviderStateMixin {
  late AnimationController _controller;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
      if (mounted) {
        setState(() {
          _progress = _controller.value;
        });
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The progress bar background and shimmer effect
            Stack(
              children: [
                Container(color: Colors.grey[800]), // Background
                FractionallySizedBox(
                  widthFactor: _progress,
                  alignment: Alignment.centerLeft,
                  child: Shimmer.fromColors(
                    baseColor: Colors.deepPurple,
                    highlightColor: Colors.purple.shade300,
                    child: Container(color: Colors.white), // Shimmer needs a solid child
                  ),
                ),
              ],
            ),
            // The text on top
            Text(
              widget.message,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                shadows: [
                  const Shadow(blurRadius: 4.0, color: Colors.black87, offset: Offset(1,1)),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library, size: 100, color: Theme.of(context).colorScheme.primary.withAlpha(178)),
          const SizedBox(height: 24),
          Text('Press "Sort" to Begin', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Text('Let the AI find photos you can delete', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center,),
        ],
      ),
    );
  }
}