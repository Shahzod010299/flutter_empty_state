import 'package:flutter/material.dart';

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

    final scheme = Theme.of(context).colorScheme;
    final base = _skeletonBase(scheme);
    final highlight = _skeletonHighlight(scheme);

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            colors: [base, highlight, base],
            stops: const [0.35, 0.5, 0.65],
            transform: _SlidingGradient(_controller.value),
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

// Slides the highlight from just off the left edge to just off the right.
class _SlidingGradient extends GradientTransform {
  const _SlidingGradient(this.value);

  final double value;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues((value * 2 - 1) * bounds.width, 0, 0);
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
        color: _skeletonBase(Theme.of(context).colorScheme),
        borderRadius: borderRadius,
      ),
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
        child: ListView.separated(
          padding: padding,
          itemCount: itemCount,
          // It's a placeholder, so there's nothing to scroll to.
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => SizedBox(height: itemSpacing),
          itemBuilder: (context, index) => _SkeletonRow(hasLeading: hasLeading),
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

// Skeleton colours are blended from the scheme so they read correctly in both
// light and dark without any hard-coded greys.
Color _skeletonBase(ColorScheme scheme) =>
    Color.lerp(scheme.surface, scheme.onSurface, 0.13)!;

Color _skeletonHighlight(ColorScheme scheme) =>
    Color.lerp(scheme.surface, scheme.onSurface, 0.05)!;
