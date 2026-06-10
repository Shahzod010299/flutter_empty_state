import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'empty_state.dart';
import 'error_state.dart';
import 'loading_state.dart';
import 'no_internet_state.dart';
import 'view_state.dart';

/// Picks what to render based on the current [ViewState], and cross-fades
/// between states as it changes.
///
/// Instead of scattering `if (loading) ... else if (error) ...` across your
/// build methods, describe each case once and switch on a single value:
///
/// ```dart
/// StateView(
///   state: state,
///   loading: const LoadingState(),
///   empty: const EmptyState(title: 'No products found'),
///   error: ErrorState(onAction: _retry),
///   noInternet: NoInternetState(onRetry: _retry),
///   child: ProductList(products: products),
/// )
/// ```
///
/// Any slot you leave out falls back to a sensible default, so you only fill in
/// the ones you want to customise. Pass [onRetry] and the default error and
/// no-internet states come pre-wired with a working retry button:
///
/// ```dart
/// StateView(state: state, onRetry: _load, child: ProductList(...))
/// ```
class StateView extends StatelessWidget {
  const StateView({
    super.key,
    required this.state,
    this.child,
    this.loading,
    this.empty,
    this.error,
    this.noInternet,
    this.onRetry,
    this.animate = true,
    this.duration = const Duration(milliseconds: 300),
    this.transitionBuilder,
  });

  /// Which state to show right now.
  final ViewState state;

  /// Shown for [ViewState.content] — your actual screen.
  final Widget? child;

  /// {@template fes.stateview.loading}
  /// Shown for [ViewState.loading]. Defaults to a [LoadingState].
  /// {@endtemplate}
  final Widget? loading;

  /// {@template fes.stateview.empty}
  /// Shown for [ViewState.empty]. Defaults to an [EmptyState].
  /// {@endtemplate}
  final Widget? empty;

  /// {@template fes.stateview.error}
  /// Shown for [ViewState.error]. Defaults to an [ErrorState].
  /// {@endtemplate}
  final Widget? error;

  /// {@template fes.stateview.noInternet}
  /// Shown for [ViewState.noInternet]. Defaults to a [NoInternetState].
  /// {@endtemplate}
  final Widget? noInternet;

  /// Wires the retry button of the *default* [error] and [noInternet] widgets,
  /// so the common case needs no explicit `ErrorState` at all. Ignored for
  /// slots you've filled in yourself. Returning a [Future] shows inline
  /// progress on the button until it completes.
  final FutureOr<void> Function()? onRetry;

  /// Whether to cross-fade when [state] changes. Defaults to `true`, and is
  /// skipped automatically when the OS "reduce motion" setting is on.
  final bool animate;

  /// Duration of the cross-fade between states.
  final Duration duration;

  /// Customises the transition between states — same contract as
  /// [AnimatedSwitcher.transitionBuilder]. Defaults to a cross-fade.
  ///
  /// ```dart
  /// StateView(
  ///   state: state,
  ///   transitionBuilder: (child, animation) =>
  ///       ScaleTransition(scale: animation, child: child),
  ///   child: list,
  /// )
  /// ```
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  Widget _childFor(ViewState state) {
    switch (state) {
      case ViewState.loading:
        return loading ?? const LoadingState();
      case ViewState.empty:
        return empty ?? const EmptyState();
      case ViewState.error:
        return error ?? ErrorState(onAction: onRetry);
      case ViewState.noInternet:
        return noInternet ?? NoInternetState(onRetry: onRetry);
      case ViewState.content:
        return child ?? const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _childFor(state);

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!animate || reduceMotion || duration == Duration.zero) {
      return current;
    }

    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder:
          transitionBuilder ?? AnimatedSwitcher.defaultTransitionBuilder,
      // Key by the state so the switcher knows a real change happened and
      // cross-fades, rather than reusing the old element in place.
      child: KeyedSubtree(key: ValueKey<ViewState>(state), child: current),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<ViewState>('state', state))
      ..add(FlagProperty('animate', value: animate, ifFalse: 'no transition'));
  }
}
