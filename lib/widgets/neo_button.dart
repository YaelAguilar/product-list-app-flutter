import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final double? width;
  final double? height;

  const NeoButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  NeoButtonState createState() => NeoButtonState();
}

class NeoButtonState extends State<NeoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height ?? 56,
              decoration: BoxDecoration(
                gradient: widget.isSecondary
                    ? LinearGradient(
                        colors: [
                          AppTheme.cardBackground,
                          AppTheme.secondaryDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          AppTheme.accentGreen,
                          AppTheme.accentGreenDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isSecondary
                      ? AppTheme.borderColor
                      : AppTheme.accentGreen.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSecondary
                        ? Colors.black.withValues(alpha: 0.3)
                        : AppTheme.accentGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isLoading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.isSecondary
                                    ? AppTheme.accentGreen
                                    : AppTheme.primaryDark,
                              ),
                            ),
                          )
                        else if (widget.icon != null)
                          Icon(
                            widget.icon,
                            color: widget.isSecondary
                                ? AppTheme.textPrimary
                                : AppTheme.primaryDark,
                            size: 18,
                          ),
                        if ((widget.icon != null || widget.isLoading) &&
                            widget.text.isNotEmpty)
                          SizedBox(width: 8),
                        if (widget.text.isNotEmpty)
                          Flexible(
                            child: Text(
                              widget.text,
                              style: TextStyle(
                                color: widget.isSecondary
                                    ? AppTheme.textPrimary
                                    : AppTheme.primaryDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
