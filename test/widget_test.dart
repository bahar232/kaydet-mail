import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import 'package:kaydet_mail/app.dart';

void main() {
  setUp(() {
    SharedPreferencesStorePlatform.instance = InMemorySharedPreferencesStore.empty();
  });

  testWidgets('App boots to the login screen with no saved account', (WidgetTester tester) async {
    await tester.pumpWidget(const KaydetApp());

    // The initial CircularProgressIndicator animates indefinitely, so
    // pumpAndSettle would never return; pump past the async session check
    // (SharedPreferences load) with a fixed step instead.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('KAYDET'), findsWidgets);
    expect(find.text('Giriş Yap'), findsOneWidget);
  });
}
