
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SortingIndicatorBar extends StatefulWidget {
  final String message;
  final Color neonColor;

  const SortingIndicatorBar({
    super.key,
    required this.message,
    required this.neonColor,
  });

  @override
  State<SortingIndicatorBar> createState() => _SortingIndicatorBarState();
}

class _SortingIndicatorBarState extends State<SortingIndicatorBar>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    // Progress animation to create a back-and-forth scanning effect
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Glow animation for a subtle pulsing effect
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInQuad),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.neonColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.neonColor.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            // Animated Gradient for the scanning effect
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Positioned.fill(
                  child: FractionallySizedBox(
                    widthFactor: 1.5, // Make it wider to animate across
                    alignment: Alignment(_progressController.value * 2 - 1, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            widget.neonColor.withOpacity(0.4),
                            Colors.transparent,
                          ],
                          stops: const [0.2, 0.5, 0.8],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Pulsing Glow Effect
            Center(
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: widget.neonColor.withOpacity(0.3),
                          blurRadius: _glowAnimation.value,
                          spreadRadius: _glowAnimation.value / 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Message Text
            Center(
              child: Text(
                widget.message,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
