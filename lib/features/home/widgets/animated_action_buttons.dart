import 'package:flutter/material.dart';
import 'package:be_kind/app/theme/app_colors.dart';

class AnimatedActionButtons extends StatefulWidget {
  const AnimatedActionButtons({
    required this.onComplete,
    required this.onSwap,
    super.key,
  });

  final VoidCallback onComplete;
  final VoidCallback onSwap;

  @override
  State<AnimatedActionButtons> createState() => _AnimatedActionButtonsState();
}

class _AnimatedActionButtonsState extends State<AnimatedActionButtons>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Primary animated "I did it" button
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _controller.reverse();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _controller.forward();
              widget.onComplete();
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _controller.forward();
            },
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.accent,
                      Color(0xFF24563F),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: _isPressed ? 0.2 : 0.38),
                      blurRadius: _isPressed ? 8 : 16,
                      offset: Offset(0, _isPressed ? 2 : 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'I did it',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Secondary "Swap task" button with icon
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: widget.onSwap,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(48, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: const BorderSide(color: AppColors.lineStrong, width: 1.5),
              backgroundColor: AppColors.surface,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.shuffle, size: 18, color: AppColors.ink),
                SizedBox(width: 6),
                Text('Swap', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
