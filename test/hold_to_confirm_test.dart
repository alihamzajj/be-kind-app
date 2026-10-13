import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:be_kind/core/widgets/motion.dart';

void main() {
  Widget host(VoidCallback onConfirmed) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: HoldToConfirmButton(
                label: 'Hold: I did it',
                holdingLabel: 'Keep holding',
                onConfirmed: onConfirmed,
              ),
            ),
          ),
        ),
      );

  testWidgets('a quick tap does not confirm', (tester) async {
    var confirmed = 0;
    await tester.pumpWidget(host(() => confirmed++));
    await tester.tap(find.text('Hold: I did it'));
    await tester.pump(const Duration(seconds: 2));
    expect(confirmed, 0);
  });

  testWidgets('holding until the bar fills confirms once', (tester) async {
    var confirmed = 0;
    await tester.pumpWidget(host(() => confirmed++));
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Hold: I did it')),
    );
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Keep holding'), findsOneWidget);
    for (var i = 0; i < 24; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(confirmed, 1);
    await gesture.up();
    await tester.pump(const Duration(seconds: 1));
    expect(confirmed, 1);
  });

  testWidgets('releasing early does not confirm', (tester) async {
    var confirmed = 0;
    await tester.pumpWidget(host(() => confirmed++));
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Hold: I did it')),
    );
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await gesture.up();
    await tester.pump(const Duration(seconds: 2));
    expect(confirmed, 0);
  });
}
