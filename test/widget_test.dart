import 'package:flutter_test/flutter_test.dart';
import 'package:p_lyric/main.dart';

void main() {
  testWidgets('test appbar title', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.text('PLyric'), findsOneWidget);
  });
}
