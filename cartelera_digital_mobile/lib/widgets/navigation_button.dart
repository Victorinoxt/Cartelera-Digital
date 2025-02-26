import 'package:flutter/material.dart';

class NavigationButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? iconSize;
  final EdgeInsets? padding;
  final bool showOnHover;

  const NavigationButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.iconSize,
    this.padding,
    this.showOnHover = true,
  });

  @override
  State<NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<NavigationButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.showOnHover
            ? (_isHovered || _isPressed ? 1.0 : 0.3)
            : 1.0,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: Container(
            padding: widget.padding ?? const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? 
                    Colors.black.withOpacity(_isPressed ? 0.5 : 0.3),
              borderRadius: BorderRadius.circular(30),
              boxShadow: _isHovered || _isPressed
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: widget.onPressed,
                child: Icon(
                  widget.icon,
                  color: widget.iconColor ?? Colors.white,
                  size: widget.iconSize ?? 36,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 