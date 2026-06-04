/// The states a screen usually moves through while it loads something.
///
/// Feed one of these to a [StateView] and it picks the matching widget for you.
enum ViewState {
  /// Work is still in flight (a request, a query, a file read...).
  loading,

  /// Finished loading, but there's nothing to show.
  empty,

  /// Something went wrong.
  error,

  /// A specific kind of error: the device is offline.
  noInternet,

  /// Finished loading and there's real content to display.
  content,
}
