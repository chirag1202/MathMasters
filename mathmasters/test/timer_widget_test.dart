import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathmasters/widgets/timer_circle.dart';

void main() {
  testWidgets('TimerCircle shows seconds and progress', (tester) async {
    const total = Duration(seconds: 100);
    const remaining = Duration(seconds: 25);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TimerCircle(remaining: remaining, total: total),
        ),
      ),
    );

    expect(find.text('25s'), findsOneWidget);
    // Finds a CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
