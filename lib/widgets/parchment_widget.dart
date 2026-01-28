import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ParchmentWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? borderRadius;

  const ParchmentWidget({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Effet de parchemin vieilli
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.medievalCream,
            AppTheme.medievalCream.withValues(alpha: 0.95),
            const Color(0xFFE8DCC0), // Teinte plus foncée pour effet vieilli
            AppTheme.medievalCream.withValues(alpha: 0.9),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        border: Border.all(
          color: AppTheme.medievalBronze.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          // Ombre principale
          BoxShadow(
            color: AppTheme.medievalDarkBrown.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          // Ombre interne pour effet de profondeur
          BoxShadow(
            color: AppTheme.medievalDarkBrown.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Effets de brûlure/patine
          Positioned(
            top: 10,
            right: 15,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppTheme.medievalBrown.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            child: Container(
              width: 20,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.medievalBrown.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 30,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: AppTheme.medievalBrown.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Contenu
          child,
        ],
      ),
    );
  }
}
