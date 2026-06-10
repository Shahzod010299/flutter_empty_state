import 'package:flutter/material.dart';

import 'empty_state_theme.dart';

/// An animated shimmer that sweeps a soft highlight across its child.
///
/// Wrap a group of [Skeleton]s in a single [Shimmer] so the highlight runs
/// across all of them together, the way real skeleton screens do. It honours
/// the OS "reduce motion" setting by falling back to a still placeholder.
///
/// ```dart
/// Shimmer(
///   child: Column(
///     children: const [Skeleton(height: 16), SizedBox(height: 8), Skeleton()],
///   ),
/// )
/// ```
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 1400),
  });

  /// The skeleton subtree to animate.
  final Widget child;

  /// How long a single sweep takes.
  final Duration period;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.period);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller.stop();
      return widget.child; // still skeleton, just not moving
    }
    if (!_controller.isAnimating) _controller.repeat();

    final base = _skeletonBase(context);
    final highlight = _skeletonHighlight(context);
    // Sweep in the reading direction, so RTL locales shimmer right-to-left.
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            colors: [base, highlight, base],
            stops: const [0.35, 0.5, 0.65],
            transform: _SlidingGradient(_controller.value, direction),
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

// Slides the highlight from just off one edge to just off the other,
// following the ambient text direction.
class _SlidingGradient extends GradientTransform {
  const _SlidingGradient(this.value, this.direction);

  final double value;
  final TextDirection direction;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final dx = (value * 2 - 1) * bounds.width;
    return Matrix4.translationValues(
        direction == TextDirection.rtl ? -dx : dx, 0, 0);
  }
}

/// A single shimmering placeholder — a line, a box or (via [Skeleton.circle])
/// an avatar.
///
/// On its own it shows a static muted shape; placed inside a [Shimmer] it picks
/// up the moving highlight.
class Skeleton extends StatelessWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  /// A round placeholder, handy for avatars.
  const Skeleton.circle({super.key, required double size})
      : width = size,
        height = size,
        borderRadius = const BorderRadius.all(Radius.circular(1000));

  /// Width. Null means "fill the available width".
  final double? width;

  /// Height.
  final double height;

  /// Corner radius.
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: _skeletonBase(context),
        borderRadius: borderRadius,
      ),
    );
  }
}

/// A few stacked [Skeleton] lines that stand in for a block of text, with a
/// shorter last line the way real paragraphs end.
///
/// ```dart
/// Shimmer(
///   child: SkeletonParagraph(lines: 3),
/// )
/// ```
class SkeletonParagraph extends StatelessWidget {
  const SkeletonParagraph({
    super.key,
    this.lines = 3,
    this.lineHeight = 14,
    this.spacing = 10,
    this.lastLineWidthFraction = 0.6,
  })  : assert(lines > 0, 'lines must be at least 1'),
        assert(
          lastLineWidthFraction > 0 && lastLineWidthFraction <= 1,
          'lastLineWidthFraction must be in (0, 1]',
        );

  /// How many placeholder lines to draw.
  final int lines;

  /// Height of each line.
  final double lineHeight;

  /// Vertical gap between lines.
  final double spacing;

  /// Width of the last line as a fraction of the full width. Ignored when
  /// there's only one line.
  final double lastLineWidthFraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines; i++) ...[
          if (i > 0) SizedBox(height: spacing),
          if (i == lines - 1 && lines > 1)
            FractionallySizedBox(
              widthFactor: lastLineWidthFraction,
              alignment: AlignmentDirectional.centerStart,
              child: Skeleton(height: lineHeight),
            )
          else
            Skeleton(height: lineHeight),
        ],
      ],
    );
  }
}

/// A ready-made shimmering placeholder list — drop it straight into a loading
/// state instead of a spinner:
///
/// ```dart
/// StateView(state: state, loading: const SkeletonList(), child: list)
/// ```
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 6,
    this.padding = const EdgeInsets.all(16),
    this.itemSpacing = 22,
    this.hasLeading = true,
  });

  /// How many placeholder rows to show.
  final int itemCount;

  /// Padding around the list.
  final EdgeInsetsGeometry padding;

  /// Vertical gap between rows.
  final double itemSpacing;

  /// Whether each row shows a leading circle (an avatar placeholder).
  final bool hasLeading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      container: true,
      child: Shimmer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ListView.separated(
              padding: padding,
              itemCount: itemCount,
              // Inside an unbounded parent (a Column, another scrollable) a
              // ListView can't expand, so size it to its children instead.
              shrinkWrap: !constraints.hasBoundedHeight,
              // It's a placeholder, so there's nothing to scroll to.
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) =>
                  SizedBox(height: itemSpacing),
              itemBuilder: (context, index) =>
                  _SkeletonRow(hasLeading: hasLeading),
            );
          },
        ),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({required this.hasLeading});

  final bool hasLeading;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasLeading) ...const [
          Skeleton.circle(size: 48),
          SizedBox(width: 16),
        ],
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(height: 14),
              SizedBox(height: 10),
              Skeleton(width: 160, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

// Skeleton colours come from the EmptyStateTheme when set; otherwise they're
// blended from the scheme so they read correctly in both light and dark
// without any hard-coded greys.
Color _skeletonBase(BuildContext context) {
  final theme = Theme.of(context);
  return theme.extension<EmptyStateTheme>()?.skeletonBaseColor ??
      Color.lerp(theme.colorScheme.surface, theme.colorScheme.onSurface, 0.13)!;
}

Color _skeletonHighlight(BuildContext context) {
  final theme = Theme.of(context);
  return theme.extension<EmptyStateTheme>()?.skeletonHighlightColor ??
      Color.lerp(theme.colorScheme.surface, theme.colorScheme.onSurface, 0.05)!;
}
