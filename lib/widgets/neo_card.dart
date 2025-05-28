import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool glowEffect;

  const NeoCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.glowEffect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.cardBackground,
            AppTheme.secondaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: glowEffect
              ? AppTheme.accentGreen.withValues(alpha: 0.5)
              : AppTheme.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: glowEffect
                ? AppTheme.accentGreen.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.3),
            blurRadius: glowEffect ? 12 : 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
