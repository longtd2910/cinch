import 'dart:math' as math;

import 'package:flutter/material.dart';

class ShakeOnInvalid extends StatefulWidget {
  const ShakeOnInvalid({
    super.key,
    required this.isInvalid,
    required this.errorTick,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.borderWidth = 2,
    this.shakeAmplitude = 8,
    this.duration = const Duration(milliseconds: 450),
  });

  final bool isInvalid;
  final int errorTick;
  final Widget child;
  final BorderRadius borderRadius;
  final double borderWidth;
  final double shakeAmplitude;
  final Duration duration;

  @override
  State<ShakeOnInvalid> createState() => _ShakeOnInvalidState();
}

class _ShakeOnInvalidState extends State<ShakeOnInvalid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
  }

  @override
  void didUpdateWidget(ShakeOnInvalid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorTick != oldWidget.errorTick && widget.isInvalid) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor = widget.isInvalid ? cs.error : Colors.transparent;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final dx = t == 0
            ? 0.0
            : math.sin(t * math.pi * 6) * widget.shakeAmplitude * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(widget.borderWidth),
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          border: Border.all(color: borderColor, width: widget.borderWidth),
        ),
        child: widget.child,
      ),
    );
  }
}
