import 'package:flutter/material.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final Curve curve;
  final double hoverElevation;
  final double normalElevation;
  final bool enabled;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.hoverElevation = 12.0,
    this.normalElevation = 2.0,
    this.enabled = true,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _elevationAnimation = Tween<double>(
      begin: widget.normalElevation,
      end: widget.hoverElevation,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enabled) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enabled) _controller.reverse();
    if (widget.onTap != null) widget.onTap!();
  }

  void _onTapCancel() {
    if (widget.enabled) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Material(
                elevation: _isHovering ? _elevationAnimation.value : widget.normalElevation,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// أنيميشن ظهور البطاقات (Staggered Animation)
class StaggeredGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  final Duration animationDelay;

  const StaggeredGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.spacing = 16,
    this.animationDelay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1.2,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _getAnimationController(index),
            curve: Curves.easeOut,
          ),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _getAnimationController(index),
              curve: Curves.easeOutBack,
            ),
            child: children[index],
          ),
        );
      },
    );
  }

  AnimationController _getAnimationController(int index) {
    final controller = AnimationController(
      vsync: _AnimationState(),
      duration: Duration(milliseconds: 400 + (index * animationDelay.inMilliseconds).toInt()),
    )..forward();
    return controller;
  }
}

class _AnimationState extends StatefulWidget {
  @override
  State<_AnimationState> createState() => _AnimationStateState();
}

class _AnimationStateState extends State<_AnimationState> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
