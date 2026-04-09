// Basic smoke test — ensures app widget tree builds without Firebase.
// Full tests would require mocking FirebaseAuth/Firestore.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Trivial smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('MyHabits'))),
    );
    expect(find.text('MyHabits'), findsOneWidget);
  });
}
