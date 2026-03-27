import 'package:flutter_test/flutter_test.dart';
import 'package:gallery_music/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const GalleryMusicApp());
    expect(find.text('Gallery'), findsWidgets);
  });
}
