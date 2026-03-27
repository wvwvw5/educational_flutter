import 'package:flutter_test/flutter_test.dart';
import 'package:api_explorer/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ApiExplorerApp());
    expect(find.text('Animals'), findsOneWidget);
  });
}
