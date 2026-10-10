import 'package:flutter_test/flutter_test.dart';
import 'package:astraluna/main.dart';

void main() {
  testWidgets('Astraluna app loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AstralunaApp());
    expect(find.text('ASTRALUNA STARGAZER COMPASS'), findsOneWidget);
  });
}
