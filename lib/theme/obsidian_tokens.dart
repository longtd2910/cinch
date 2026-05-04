import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

class ObsidianSpacing extends ThemeExtension<ObsidianSpacing> {
  const ObsidianSpacing({
    required this.unit,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.margin,
    required this.gutter,
  });

  final double unit;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double margin;
  final double gutter;

  static const ObsidianSpacing obsidian = ObsidianSpacing(
    unit: 4,
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
    xxl: 48,
    margin: 20,
    gutter: 12,
  );

  @override
  ObsidianSpacing copyWith({
    double? unit,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? margin,
    double? gutter,
  }) {
    return ObsidianSpacing(
      unit: unit ?? this.unit,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      margin: margin ?? this.margin,
      gutter: gutter ?? this.gutter,
    );
  }

  @override
  ObsidianSpacing lerp(ThemeExtension<ObsidianSpacing>? other, double t) {
    if (other is! ObsidianSpacing) return this;
    return ObsidianSpacing(
      unit: lerpDouble(unit, other.unit, t)!,
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xxl: lerpDouble(xxl, other.xxl, t)!,
      margin: lerpDouble(margin, other.margin, t)!,
      gutter: lerpDouble(gutter, other.gutter, t)!,
    );
  }
}

class ObsidianRadii extends ThemeExtension<ObsidianRadii> {
  const ObsidianRadii({
    required this.sm,
    required this.normal,
    required this.md,
    required this.lg,
    required this.xl,
    required this.full,
  });

  final double sm;
  final double normal;
  final double md;
  final double lg;
  final double xl;
  final double full;

  static const ObsidianRadii obsidian = ObsidianRadii(
    sm: 4,
    normal: 8,
    md: 12,
    lg: 16,
    xl: 24,
    full: 9999,
  );

  @override
  ObsidianRadii copyWith({
    double? sm,
    double? normal,
    double? md,
    double? lg,
    double? xl,
    double? full,
  }) {
    return ObsidianRadii(
      sm: sm ?? this.sm,
      normal: normal ?? this.normal,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      full: full ?? this.full,
    );
  }

  @override
  ObsidianRadii lerp(ThemeExtension<ObsidianRadii>? other, double t) {
    if (other is! ObsidianRadii) return this;
    return ObsidianRadii(
      sm: lerpDouble(sm, other.sm, t)!,
      normal: lerpDouble(normal, other.normal, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      full: lerpDouble(full, other.full, t)!,
    );
  }
}

extension ObsidianThemeX on BuildContext {
  ObsidianSpacing get obsidianSpacing =>
      Theme.of(this).extension<ObsidianSpacing>()!;

  ObsidianRadii get obsidianRadii => Theme.of(this).extension<ObsidianRadii>()!;
}
