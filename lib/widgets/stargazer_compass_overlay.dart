import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class StargazerCompassOverlay extends StatefulWidget {
  final VoidCallback onFinished;
  final bool isAstroRedMode;

  const StargazerCompassOverlay({
    super.key,
    required this.onFinished,
    this.isAstroRedMode = false,
  });

  @override
  State<StargazerCompassOverlay> createState() => _StargazerCompassOverlayState();
}

class _StargazerCompassOverlayState extends State<StargazerCompassOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _countdownTimer;
  int _secondsRemaining = 5;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 1) {
          _secondsRemaining--;
        } else {
          _countdownTimer?.cancel();
          widget.onFinished();
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isAstroRedMode ? Colors.redAccent : const Color(0xFF00E5FF);
    final accentColor = widget.isAstroRedMode ? Colors.red : const Color(0xFFFFC107);
    final bgColor = widget.isAstroRedMode ? const Color(0xFF100000) : const Color(0xFF0B0E17);

    return Container(
      color: bgColor.withOpacity(0.95),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top branding title
            Text(
              'ASTRALUNA STARGAZER COMPASS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Calibrating Rooftop Sky Directions...',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
            const SizedBox(height: 36),

            // Compass Dial Animation
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                // Subtle pendulum rotation between -15° and +15°
                final angle = sin(_animationController.value * 2 * pi) * 0.25;

                return Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor.withOpacity(0.8), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.25),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Inner ring
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: accentColor.withOpacity(0.5), width: 1.5),
                          ),
                        ),

                        // Cardinal Directions: N, E, S, W
                        Positioned(
                          top: 14,
                          child: Text(
                            'N',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                          ),
                        ),
                        Positioned(
                          bottom: 14,
                          child: Text(
                            'S',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[400]),
                          ),
                        ),
                        Positioned(
                          right: 18,
                          child: Text(
                            'E',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentColor),
                          ),
                        ),
                        Positioned(
                          left: 18,
                          child: Text(
                            'W',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[400]),
                          ),
                        ),

                        // Compass Needle Pointer
                        Transform.rotate(
                          angle: -angle * 2, // Counter rotation for realistic needle dynamics
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.navigation, size: 56, color: primaryColor),
                              const SizedBox(height: 20),
                              Icon(Icons.navigation, size: 36, color: Colors.grey[600]),
                            ],
                          ),
                        ),

                        // Center Pivot Dot
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Instructions text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Hold phone flat facing East/North to align rooftop coordinates.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[300]),
              ),
            ),

            const SizedBox(height: 28),

            // Countdown & Skip Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: const Icon(Icons.stars, size: 18),
              label: Text(
                'Entering App in ${_secondsRemaining}s • Skip',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: widget.onFinished,
            ),
          ],
        ),
      ),
    );
  }
}
