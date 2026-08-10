import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:security_ia_fem/app.dart';
import 'package:security_ia_fem/providers/auth_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const InnovaSecurityApp(),
      ),
    );

    expect(find.byType(InnovaSecurityApp), findsOneWidget);
  });
}
