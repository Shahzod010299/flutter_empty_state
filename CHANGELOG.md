# Changelog

## 0.2.0

- **Pull-to-refresh**: new `onRefresh` on `EmptyState`, `ErrorState`,
  `NoInternetState` and `SearchEmptyState` wraps the state in a
  `RefreshIndicator` with an always-scrollable viewport — pull down to reload
  even when there's no list on screen.
- **Async action buttons**: action callbacks (`onAction`, `onRetry`,
  `onClear`) now accept `FutureOr<void>`. When a callback returns a `Future`,
  the button disables itself and shows an inline progress indicator until it
  completes.
- **Secondary action**: optional `secondaryActionText` / `onSecondaryAction`
  render a `TextButton` under the main action (e.g. "Retry" + "Go back").
- **`ErrorState.details`**: collapsible, selectable technical details behind a
  "Details" disclosure — perfect for raw exception text in bug-report flows.
- **`StateView.onRetry`**: wires the retry button of the default error and
  no-internet states, so `StateView(state: s, onRetry: _load, child: ...)` is
  a complete screen.
- **`StateView.transitionBuilder`**: customise the transition between states
  (same contract as `AnimatedSwitcher.transitionBuilder`).
- **`SkeletonParagraph`**: a text-block placeholder with a shorter last line.
- `SkeletonList` now works inside unbounded-height parents (a `Column`,
  another scrollable) instead of throwing.
- The shimmer sweep follows the ambient text direction (RTL support).
- `EmptyStateTheme` gains `secondaryButtonStyle`, `skeletonBaseColor` and
  `skeletonHighlightColor`.

## 0.1.2

- Declare supported platforms (Android, iOS, web, Windows, macOS, Linux)
  explicitly so pub.dev lists them.

## 0.1.1

- Fix the preview screenshots not showing on the pub.dev README (use absolute
  image URLs instead of relative paths).

## 0.1.0

First release.

- `EmptyState`, `ErrorState`, `NoInternetState`, `SearchEmptyState` and `LoadingState`.
- `StateView` + `ViewState` to switch between loading / empty / error / offline / content from a single value, with a cross-fade between states.
- `EmptyStateTheme` (a `ThemeExtension`) to set your defaults once for the whole app. Resolution order is explicit argument → theme → built-in default.
- Theme-aware defaults with full light & dark support.
- Subtle fade + slide entrance animation that honours the OS "reduce motion" setting; fully opt-out.
- `SkeletonList`, plus `Shimmer` and `Skeleton` primitives, for a shimmer-based loading placeholder.
- Accessibility: real text widgets, decorative icons, and a live region on the loading state.
- Everything is overridable: icon, custom illustration, title, message, action button, icon size, spacing, padding, max content width, text alignment, and the text / button styles.
- `debugFillProperties` on every widget for a friendlier DevTools inspector.
- No runtime dependencies.
