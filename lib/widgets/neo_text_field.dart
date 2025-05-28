import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeoTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool showPasswordToggle;

  const NeoTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.showPasswordToggle = false,
  });

  @override
  NeoTextFieldState createState() => NeoTextFieldState();
}

class NeoTextFieldState extends State<NeoTextField> {
  bool _isFocused = false;
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? AppTheme.accentGreen.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: TextField(
          controller: widget.controller,
          obscureText: _isObscured,
          keyboardType: widget.keyboardType,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused
                        ? AppTheme.accentGreen
                        : AppTheme.textSecondary,
                  )
                : null,
            suffixIcon: widget.showPasswordToggle
                ? IconButton(
                    icon: Icon(
                      _isObscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _isFocused
                          ? AppTheme.accentGreen
                          : AppTheme.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: AppTheme.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.accentGreen, width: 2),
            ),
            labelStyle: TextStyle(
              color: _isFocused
                  ? AppTheme.accentGreen
                  : AppTheme.textSecondary,
            ),
            hintStyle: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
