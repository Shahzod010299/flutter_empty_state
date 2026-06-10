import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_empty_state/flutter_empty_state.dart';

void main() => runApp(const ExampleApp());

/// A tiny gallery that lets you flip through every state the package ships,
/// in both light and dark mode.
class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

// The demo's own list of "screens". Most map straight onto a ViewState; the
// extras (search, skeleton, grid, success) aren't part of ViewState.
enum _Demo {
  content,
  loading,
  skeleton,
  grid,
  empty,
  search,
  error,
  noInternet,
  success,
}

// A few of the bundled locales, to show off the localized default copy.
const _locales = [
  Locale('en'),
  Locale('uz'),
  Locale('ru'),
  Locale('ar'),
];

class _ExampleAppState extends State<ExampleApp> {
  _Demo _demo = _Demo.empty;
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _cycleLocale() {
    setState(() {
      final next = (_locales.indexOf(_locale) + 1) % _locales.length;
      _locale = _locales[next];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      locale: _locale,
      // Registering the delegate localizes every default string. The package
      // falls back to English for any locale you don't list here.
      localizationsDelegates: const [
        EmptyStateLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: EmptyStateLocalizations.supportedLocales,
      // Registering an EmptyStateTheme styles every state widget at once — here
      // we just nudge the spacing. Per-widget arguments still override it.
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        extensions: const [EmptyStateTheme(spacing: 18)],
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
        extensions: const [EmptyStateTheme(spacing: 18)],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('flutter_empty_state'),
          actions: [
            TextButton(
              onPressed: _cycleLocale,
              child: Text(
                _locale.languageCode.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              tooltip: 'Toggle light / dark',
              onPressed: _toggleTheme,
              icon: Icon(_themeMode == ThemeMode.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined),
            ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: _DemoPicker(
          value: _demo,
          onChanged: (demo) => setState(() => _demo = demo),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // The skeleton loaders are drop-in alternatives to a plain spinner.
    if (_demo == _Demo.skeleton) {
      return const SkeletonList();
    }
    if (_demo == _Demo.grid) {
      return const SkeletonGrid();
    }

    // These aren't ViewStates, so they get their own branches.
    if (_demo == _Demo.search) {
      return SearchEmptyState(
        query: 'iPhone 99',
        onClear: () => setState(() => _demo = _Demo.content),
      );
    }
    if (_demo == _Demo.success) {
      return SuccessState(
        title: 'Order placed',
        message: 'We\'ll email you a receipt shortly.',
        actionText: 'Back to products',
        onAction: () => setState(() => _demo = _Demo.content),
      );
    }

    return StateView(
      state: _viewStateFor(_demo),
      loading: const LoadingState(message: 'Loading products...'),
      empty: EmptyState(
        title: 'No products yet',
        message: 'When you add products, they will show up here.',
        actionText: 'Add product',
        onAction: () => _showSnack('Pretend we opened the add-product screen'),
        secondaryActionText: 'Learn more',
        onSecondaryAction: () => _showSnack('Pretend we opened the docs'),
        // Pull down to "reload" — the state is wrapped in a RefreshIndicator.
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 600));
          if (mounted) setState(() => _demo = _Demo.content);
        },
      ),
      error: ErrorState(
        // Returning a Future shows inline progress on the button.
        onAction: () async {
          await Future<void>.delayed(const Duration(seconds: 1));
          if (mounted) setState(() => _demo = _Demo.content);
        },
        details: 'HttpException: connection timed out\n'
            'GET https://api.example.com/products → 504',
      ),
      noInternet: NoInternetState(
        onRetry: () => setState(() => _demo = _Demo.content),
      ),
      child: const _ProductList(),
    );
  }

  ViewState _viewStateFor(_Demo demo) {
    switch (demo) {
      case _Demo.loading:
        return ViewState.loading;
      case _Demo.empty:
        return ViewState.empty;
      case _Demo.error:
        return ViewState.error;
      case _Demo.noInternet:
        return ViewState.noInternet;
      case _Demo.skeleton:
      case _Demo.grid:
      case _Demo.search:
      case _Demo.success:
      case _Demo.content:
        return ViewState.content;
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// A normal-looking list, shown when the demo is in its "content" state.
class _ProductList extends StatelessWidget {
  const _ProductList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 12,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (context, index) => ListTile(
        leading: const CircleAvatar(child: Icon(Icons.shopping_bag_outlined)),
        title: Text('Product #${index + 1}'),
        subtitle: const Text('In stock'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

/// The scrollable row of chips at the bottom that swaps between demo screens.
class _DemoPicker extends StatelessWidget {
  const _DemoPicker({required this.value, required this.onChanged});

  final _Demo value;
  final ValueChanged<_Demo> onChanged;

  static const _labels = <_Demo, String>{
    _Demo.content: 'Content',
    _Demo.loading: 'Loading',
    _Demo.skeleton: 'Skeleton',
    _Demo.grid: 'Grid',
    _Demo.empty: 'Empty',
    _Demo.search: 'Search',
    _Demo.error: 'Error',
    _Demo.noInternet: 'Offline',
    _Demo.success: 'Success',
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            for (final entry in _labels.entries)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(entry.value),
                  selected: value == entry.key,
                  onSelected: (_) => onChanged(entry.key),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
