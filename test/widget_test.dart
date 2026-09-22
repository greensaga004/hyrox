// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyrox/app/app.dart';

void main() {
  testWidgets('app boots and shows localized placeholder', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HyroxApp()));
    await tester.pumpAndSettle();

    expect(find.text('HYROX Training Tracker'), findsWidgets);
    expect(find.text('Foundation scaffold is ready.'), findsOneWidget);
  });
}
