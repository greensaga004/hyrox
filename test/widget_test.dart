// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyrox/app/app.dart';

void main() {
  testWidgets('app boots and shows session screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HyroxApp()));
    await tester.pumpAndSettle();

    expect(find.text('HYROX Training Tracker'), findsOneWidget);
    expect(find.text('Current Event'), findsOneWidget);
    expect(find.text('1. Run 1'), findsWidgets);
    expect(find.text('Start Workout'), findsOneWidget);
  });
}
