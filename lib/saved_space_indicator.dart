import 'dart:math';

import 'package:flutter/material.dart';

class SavedSpaceIndicator extends StatelessWidget {
  final double spaceSaved;
  final String formattedSpaceSaved;

  const SavedSpaceIndicator({
    super.key,
    required this.spaceSaved,
    required this.formattedSpaceSaved,
  });

  @override
  Widget build(BuildContext context) {
    // This is a mock value, it will be replaced with the actual value
    double maxMonthlyGoal = 5 * 1024 * 1024 * 1024; // 5 GB
    double progress = (spaceSaved / maxMonthlyGoal).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text('Space Saved (This Month)', style: Theme.of(context).textTheme.titleLarge)),
            Flexible(child: Text(formattedSpaceSaved, style: Theme.of(context).textTheme.titleLarge)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.green.shade400,
            ),
          ),
        ),
      ],
    );
  }
}
