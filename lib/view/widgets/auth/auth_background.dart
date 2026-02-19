import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        // Watermarks
        Positioned(
          top: 40,
          left: 20,
          child: Opacity(
            opacity: 0.1,
            child: Text(
              'Diplo',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: 20,
          child: Opacity(
            opacity: 0.1,
            child: Text(
              'masi',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
        // Top right curved shape
        Positioned(
          top: 0,
          right: 0,
          child: CustomPaint(
            size: const Size(120, 120),
            painter: CurvedShapePainter(color: scheme.primary),
          ),
        ),
        // Main content
        child,
      ],
    );
  }
}

// Custom painter for the curved shape in top right
class CurvedShapePainter extends CustomPainter {
  final Color color;
  const CurvedShapePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.3, 0)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.3,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

