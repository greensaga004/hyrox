// test/features/session/presentation/session_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hyrox/app/app.dart';

void main() {
  testWidgets(
    'session screen shows manual controls and progresses to next event',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: HyroxApp()));
      await tester.pumpAndSettle();

      expect(find.text('1. Run 1'), findsWidgets);
      expect(find.text('Start Workout'), findsOneWidget);
      expect(find.text('Auto Transition'), findsOneWidget);
      expect(find.text('Enable Auto Transition'), findsOneWidget);
      expect(find.text('Transition Delay'), findsOneWidget);
      expect(find.text('Default Rest Duration'), findsOneWidget);

      await tester.ensureVisible(find.text('Start Workout'));
      await tester.tap(find.text('Start Workout'));
      await tester.pump();

      final Finder pauseButton = find.widgetWithText(ElevatedButton, 'Pause');
      expect(tester.widget<ElevatedButton>(pauseButton).enabled, isTrue);

      await tester.ensureVisible(find.text('Complete Workout'));
      await tester.tap(find.text('Complete Workout'));
      await tester.pump();

      final Finder startRestButton = find.widgetWithText(
        ElevatedButton,
        'Start Rest',
      );
      expect(tester.widget<ElevatedButton>(startRestButton).enabled, isTrue);

      await tester.ensureVisible(find.text('Start Rest'));
      await tester.tap(find.text('Start Rest'));
      await tester.pump();

      final Finder completeRestButton = find.widgetWithText(
        ElevatedButton,
        'Complete Rest',
      );
      expect(tester.widget<ElevatedButton>(completeRestButton).enabled, isTrue);

      await tester.ensureVisible(find.text('Complete Rest'));
      await tester.tap(find.text('Complete Rest'));
      await tester.pump();

      expect(find.text('2. SkiErg'), findsWidgets);
    },
  );
}
