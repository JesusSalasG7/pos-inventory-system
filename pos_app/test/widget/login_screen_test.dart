import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/auth/presentation/screens/login_screen.dart';

import '../mocks/fake_repositories.dart';
import '../mocks/test_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  late FakeAuthRepository auth;
  late ProviderContainer container;

  Future<void> pumpLogin(WidgetTester tester) async {
    auth = FakeAuthRepository(user: supervisor());
    container = ProviderContainer(
      overrides: sessionOverrides(auth: auth, branches: FakeBranchRepository([villaLibertad])),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  testWidgets('no envía nada si faltan el usuario o la contraseña', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text(Strings.signIn));
    await tester.pumpAndSettle();

    expect(find.text(Strings.usernameRequired), findsOneWidget);
    expect(find.text(Strings.passwordRequired), findsOneWidget);
    expect(auth.loginCalls, 0);
  });

  testWidgets('la contraseña se puede mostrar y ocultar', (tester) async {
    await pumpLogin(tester);
    bool isObscured() => tester
        .widget<EditableText>(
          find.descendant(of: field(Strings.password), matching: find.byType(EditableText)),
        )
        .obscureText;

    expect(isObscured(), isTrue);
    await tester.tap(find.byTooltip(Strings.showPassword));
    await tester.pump();
    expect(isObscured(), isFalse);
    await tester.tap(find.byTooltip(Strings.hidePassword));
    await tester.pump();
    expect(isObscured(), isTrue);
  });

  testWidgets('con credenciales malas muestra un mensaje claro', (tester) async {
    await pumpLogin(tester);

    await tester.enterText(field(Strings.username), 'caja1');
    await tester.enterText(field(Strings.password), 'incorrecta');
    await tester.tap(find.text(Strings.signIn));
    await tester.pumpAndSettle();

    expect(find.text(invalidCredentials.message), findsOneWidget);
    expect(container.read(sessionControllerProvider).status, SessionStatus.unauthenticated);
  });

  testWidgets('con credenciales buenas la sesión queda lista', (tester) async {
    await pumpLogin(tester);

    await tester.enterText(field(Strings.username), 'caja1');
    await tester.enterText(field(Strings.password), 'secreta');
    await tester.tap(find.text(Strings.signIn));
    await tester.pumpAndSettle();

    expect(auth.loginCalls, 1);
    expect(container.read(sessionControllerProvider).status, SessionStatus.ready);
    expect(find.text(invalidCredentials.message), findsNothing);
  });
}
