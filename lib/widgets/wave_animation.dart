import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveAnimation extends StatefulWidget {
  final double amplitude;
  final bool isActive;
  
  const WaveAnimation({
    Key? key,
    this.amplitude = 0.0,
    this.isActive = false,
  }) : super(key: key);

  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _glowController;
  
  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _waveController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveController, _glowController]),
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(
            waveAnimation: _waveController.value,
            glowAnimation: _glowController.value,
            amplitude: widget.amplitude,
            isActive: widget.isActive,
          ),
          size: const Size.fromHeight(400),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double waveAnimation;
  final double glowAnimation;
  final double amplitude;
  final bool isActive;
  
  WavePainter({
    required this.waveAnimation,
    required this.glowAnimation,
    required this.amplitude,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseHeight = isActive ? size.height * 0.3 + (amplitude * size.height * 0.4) : size.height * 0.1;
    final glowIntensity = isActive ? 0.7 + (glowAnimation * 0.3) : 0.3 + (glowAnimation * 0.2);
    
    // Créer plusieurs couches de vagues avec des couleurs dégradées
    _paintWaveLayer(canvas, size, baseHeight * 1.2, const Color(0xFF3A4A9F), 0.8 * glowIntensity, 0);
    _paintWaveLayer(canvas, size, baseHeight * 1.0, const Color(0xFF6B7FD7), 0.9 * glowIntensity, 0.3);
    _paintWaveLayer(canvas, size, baseHeight * 0.8, const Color(0xFF8A7FDE), 0.7 * glowIntensity, 0.6);
    
    // Ajouter une lueur douce en arrière-plan
    _paintGlow(canvas, size, baseHeight, glowIntensity);
  }
  
  void _paintWaveLayer(Canvas canvas, Size size, double height, Color color, double opacity, double phaseOffset) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    final path = Path();
    path.moveTo(0, size.height);
    
    // Créer une forme ondulée organique
    for (double x = 0; x <= size.width; x += 2) {
      final wave1 = math.sin((x / size.width * 2 * math.pi) + (waveAnimation * 2 * math.pi) + phaseOffset) * 20;
      final wave2 = math.sin((x / size.width * 4 * math.pi) + (waveAnimation * 3 * math.pi) + phaseOffset) * 10;
      final wave3 = math.sin((x / size.width * 6 * math.pi) + (waveAnimation * 1.5 * math.pi) + phaseOffset) * 5;
      
      final y = size.height - height + wave1 + wave2 + wave3;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  void _paintGlow(Canvas canvas, Size size, double baseHeight, double intensity) {
    final rect = Rect.fromLTWH(0, size.height - baseHeight * 1.5, size.width, baseHeight * 1.5);
    
    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        const Color(0xFF3A4A9F).withOpacity(0.4 * intensity),
        const Color(0xFF6B7FD7).withOpacity(0.2 * intensity),
        Colors.transparent,
      ],
      stops: const [0.0, 0.7, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.waveAnimation != waveAnimation ||
           oldDelegate.glowAnimation != glowAnimation ||
           oldDelegate.amplitude != amplitude ||
           oldDelegate.isActive != isActive;
  }
}