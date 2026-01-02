import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:clean/photo_cleaner_service.dart';
import 'package:clean/l10n/app_localizations.dart';

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

  Color _getColor(double percentage) {
    const double greenEnd = 0.5;  // Stays green up to this point
    const double yellowEnd = 0.8; // Starts turning red after this point

    if (percentage <= greenEnd) {
      return Colors.green.shade400;
    } else if (percentage <= yellowEnd) {
      // Interpolate from green to yellow
      final double t = (percentage - greenEnd) / (yellowEnd - greenEnd);
      return Color.lerp(Colors.green.shade400, Colors.yellow.shade600, t)!;
    } else {
      // Interpolate from yellow to red
      final double t = (percentage - yellowEnd) / (1.0 - yellowEnd);
      return Color.lerp(Colors.yellow.shade600, Colors.red.shade500, t)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final double percentage = storageInfo.totalSpace > 0
        ? storageInfo.usedSpace / storageInfo.totalSpace
        : 0.0;

    final Color progressColor = _getColor(percentage);

    return CircularPercentIndicator(
      radius: 120.0,
      lineWidth: 16.0,
      percent: percentage,
      // The clean, modern progress bar
      progressColor: progressColor,
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
              color: progressColor,
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
