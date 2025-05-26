import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Côté gauche : Icônes X et Home
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 20,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.home, color: Colors.white, size: 24),
                    onPressed: () {
                      // Navigation vers l'accueil
                    },
                    splashRadius: 20,
                  ),
                ],
              ),
              
              // Centre : Icône signal + texte "Live"
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    child: CustomPaint(
                      painter: SignalIconPainter(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Live',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Chakra Petch',
                    ),
                  ),
                ],
              ),
              
              // Côté droit : Espace vide pour équilibrer
              const SizedBox(width: 96), // Largeur équivalente aux 2 boutons à gauche
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

class SignalIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Dessiner 3 barres de signal de hauteurs différentes
    final barWidth = size.width / 6;
    final spacing = barWidth * 0.5;
    
    // Barre 1 (plus petite)
    canvas.drawLine(
      Offset(spacing, size.height * 0.7),
      Offset(spacing, size.height),
      paint,
    );
    
    // Barre 2 (moyenne)
    canvas.drawLine(
      Offset(spacing + barWidth + spacing, size.height * 0.5),
      Offset(spacing + barWidth + spacing, size.height),
      paint,
    );
    
    // Barre 3 (plus grande)
    canvas.drawLine(
      Offset(spacing + (barWidth + spacing) * 2, size.height * 0.2),
      Offset(spacing + (barWidth + spacing) * 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}