import 'package:flutter_test/flutter_test.dart';

import 'package:test_app/main.dart';

void main() {
  testWidgets('App loads and shows dashboard content', (WidgetTester tester) async {
    await tester.pumpWidget(const ProductDashboardApp());
    await tester.pumpAndSettle();
    expect(find.text('Products'), findsOneWidget);
  });
}
