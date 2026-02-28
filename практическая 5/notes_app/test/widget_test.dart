import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/main.dart';

void main() {
  testWidgets('Notes app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NotesApp());
    expect(find.text('Мои заметки'), findsOneWidget);
    expect(find.text('Нет заметок'), findsOneWidget);
  });
}
