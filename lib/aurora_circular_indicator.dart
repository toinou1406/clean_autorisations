import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fastclean/photo_cleaner_service.dart';
import 'package:fastclean/l10n/app_localizations.dart';

/// A circular indicator to display device storage usage, redesigned to match the new UI.
class StorageCircularIndicator extends StatelessWidget {
  final StorageInfo storageInfo;

  const StorageCircularIndicator({super.key, required this.storageInfo});

  String _formatBytes(double bytes) {
    // Simple and effective byte formatting
    if (bytes <= 0) return "0 B";
    if (bytes < 1024) return "${bytes.toStringAsFixed(0)} B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    if (bytes < 1024 * 1024 * 1024) return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final double percentage = storageInfo.totalSpace > 0
        ? storageInfo.usedSpace / storageInfo.totalSpace
        : 0.0;

    return CircularPercentIndicator(
      radius: 120.0,
      lineWidth: 16.0,
      percent: percentage,
      // The clean, modern progress bar
      progressColor: theme.colorScheme.primary,
      // The subtle grey contour for the background
      backgroundColor: theme.dividerColor.withAlpha(26), // ~0.1 opacity
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 1200,
      // Center content with the new design
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            // Display percentage with the new font
            "${(percentage * 100).round()}%",
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.storageUsed.toUpperCase(), // Changed from 'used'
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153), // ~0.6 opacity
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      // Footer text showing used/total space
      footer: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Text(
          "${_formatBytes(storageInfo.usedSpace.toDouble())} / ${_formatBytes(storageInfo.totalSpace.toDouble())}",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withAlpha(204), // ~0.8 opacity
          ),
        ),
      ),
    );
  }
}
