# Changelog

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
