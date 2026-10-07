import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(const VirtualTryOnApp());
    expect(find.text('AI Virtual Try-On'), findsOneWidget);
  });
}
