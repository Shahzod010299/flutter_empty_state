// Renders the package's widgets to PNG files under `screenshots/`, with the
// real Roboto and Material Icons fonts loaded so the text isn't drawn as the
// test font's placeholder boxes.
//
// It's a headless renderer (no simulator needed). Run it with:
//
//   flutter test tool/generate_screenshots.dart
//
// It lives in tool/ so the normal `flutter test` run never picks it up.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_empty_state/flutter_empty_state.dart';

void main() {
  setUpAll(_loadRealFonts);

  testWidgets('generate screenshots', (tester) async {
    await _shoot(tester, 'empty_state_light', _empty());
    await _shoot(tester, 'empty_state_dark', _empty(), dark: true);
    await _shoot(tester, 'error_state_light', _error());
    await _shoot(tester, 'no_internet_light', _noInternet());
    await _shoot(tester, 'search_empty_light', _search());
    await _shoot(tester, 'skeleton_light', const SkeletonList(itemCount: 5),
        reduceMotion: true);

    // ignore: avoid_print
    print('Screenshots written to ${Directory('screenshots').absolute.path}');
  });
}

Widget _empty() => const EmptyState(
      animate: false,
      title: 'No products yet',
      message: 'When you add products, they will show up here.',
      actionText: 'Add product',
      onAction: _noop,
    );

Widget _error() => const ErrorState(animate: false, onAction: _noop);

Widget _noInternet() => const NoInternetState(animate: false, onRetry: _noop);

Widget _search() => const SearchEmptyState(
      animate: false,
      query: 'iPhone 15',
      onClear: _noop,
    );

Future<void> _shoot(
  WidgetTester tester,
  String name,
  Widget child, {
  bool dark = false,
  bool reduceMotion = false,
}) async {
  tester.view.physicalSize = const Size(340, 680);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final key = GlobalKey();
  Widget body = Scaffold(body: child);
  if (reduceMotion) {
    body = MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: body,
    );
  }

  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: dark ? Brightness.dark : Brightness.light,
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      fontFamily: 'Roboto',
    ),
    home: RepaintBoundary(key: key, child: body),
  ));
  await tester.pumpAndSettle();

  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    final dir = Directory('screenshots')..createSync(recursive: true);
    File('${dir.path}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

Future<void> _loadRealFonts() async {
  // The Roboto + Material Icons fonts ship inside the Flutter SDK cache. The
  // flutter tool exposes the SDK location via FLUTTER_ROOT when running tests.
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) {
    throw StateError('FLUTTER_ROOT is not set — run via `flutter test`.');
  }
  final fonts = Directory('$root/bin/cache/artifacts/material_fonts');

  Future<ByteData> bytes(String file) async =>
      ByteData.sublistView(await File('${fonts.path}/$file').readAsBytes());

  await (FontLoader('Roboto')
        ..addFont(bytes('Roboto-Regular.ttf'))
        ..addFont(bytes('Roboto-Medium.ttf')))
      .load();
  await (FontLoader('MaterialIcons')
        ..addFont(bytes('MaterialIcons-Regular.otf')))
      .load();
}

void _noop() {}
