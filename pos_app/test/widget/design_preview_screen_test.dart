import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/features/design_preview/presentation/design_preview_screen.dart';

import '../mocks/test_fonts.dart';

/// Recorre la vista previa completa en varios tamaños de pantalla. Cualquier
/// desborde de un widget global hace fallar el test.
void main() {
  setUpAll(loadAppFonts);

  const sizes = {
    'teléfono pequeño': Size(320, 640),
    'teléfono': Size(393, 852),
    'tablet': Size(820, 1180),
  };

  for (final MapEntry(key: name, value: size) in sizes.entries) {
    testWidgets('no desborda en $name', (tester) async {
      tester.view.physicalSize = size * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(theme: AppTheme.light, home: const DesignPreviewScreen()),
        ),
      );
      await tester.pump();
      expect(find.text(Strings.designPreviewTitle), findsOneWidget);
      expect(find.text(Strings.viewCart), findsOneWidget);

      final list = find.byType(Scrollable).first;
      for (var i = 0; i < 20; i++) {
        await tester.drag(list, const Offset(0, -400), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      }
      expect(find.text(Strings.previewToggleSession), findsOneWidget);
    });
  }
}
