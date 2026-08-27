import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_fight_lifecounter/main.dart';

void main() {
  testWidgets('Buddy Fight Life Counter smoke test, double tap reset, and in-card dice roll', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BuddyFightLifeCounterApp());
    await tester.pumpAndSettle();

    // Verify initial life values (10)
    expect(find.text('10'), findsNWidgets(2));

    // Verify '-' and '+' icons exist on both cards
    expect(find.byIcon(Icons.remove), findsNWidgets(2));
    expect(find.byIcon(Icons.add), findsNWidgets(2));

    // Tap right half (increment key) of Player 2 card to increment life
    await tester.tap(find.byKey(const ValueKey('p2_increment')));
    await tester.pumpAndSettle();

    expect(find.text('11'), findsOneWidget);

    // Tap left half (decrement key) of Player 1 card
    await tester.tap(find.byKey(const ValueKey('p1_decrement')));
    await tester.pumpAndSettle();

    expect(find.text('9'), findsOneWidget);

    // Test in-card dice roll
    final diceBtn = find.byTooltip('สุ่มลูกเต๋า');
    await tester.tap(diceBtn);
    // Pump past transition
    await tester.pump(const Duration(milliseconds: 350));

    // While in dice mode, '-' and '+' are hidden
    expect(find.byIcon(Icons.remove), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);

    // Advance timer to complete dice rolling
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Tap card to dismiss dice mode
    await tester.tap(find.byKey(const ValueKey('dice_view')).first);
    await tester.pumpAndSettle();

    // Verify '-' and '+' icons reappear
    expect(find.byIcon(Icons.remove), findsNWidgets(2));
    expect(find.byIcon(Icons.add), findsNWidgets(2));

    // Double tap the Reset button (sync_rounded icon)
    final resetBtn = find.byIcon(Icons.sync_rounded);
    await tester.tap(resetBtn);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(resetBtn);
    await tester.pumpAndSettle();

    // Verify both are back to 10
    expect(find.text('10'), findsNWidgets(2));
    expect(find.text('11'), findsNothing);
    expect(find.text('9'), findsNothing);
  });

  testWidgets('Dynamic player count test via Add and Delete in SettingScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const BuddyFightLifeCounterApp());
    await tester.pumpAndSettle();

    // 1. Starts with 2 players
    expect(find.byIcon(Icons.remove), findsNWidgets(2));
    expect(find.byIcon(Icons.add), findsNWidgets(2));

    // Navigate to Settings
    final settingsBtn = find.byTooltip('การตั้งค่า');
    await tester.tap(settingsBtn);
    await tester.pumpAndSettle();

    // 2. Add 3rd player
    final addBtn = find.text('เพิ่มผู้เล่น');
    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    // Save default in PlayerEditDialog
    final saveBtn = find.text('บันทึก');
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // Back to Home
    final backBtn = find.byType(BackButton);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Verify 3 cards exist (3 minus and 3 plus icons)
    expect(find.byIcon(Icons.remove), findsNWidgets(3));
    expect(find.byIcon(Icons.add), findsNWidgets(3));

    // 3. Add 4th player
    await tester.tap(find.byTooltip('การตั้งค่า'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('เพิ่มผู้เล่น'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('บันทึก'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Verify 4 cards exist
    expect(find.byIcon(Icons.remove), findsNWidgets(4));
    expect(find.byIcon(Icons.add), findsNWidgets(4));

    // 4. Delete 4th player
    await tester.tap(find.byTooltip('การตั้งค่า'));
    await tester.pumpAndSettle();
    final deleteButtons = find.byTooltip('ลบผู้เล่น');
    await tester.tap(deleteButtons.last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Verify back to 3 cards
    expect(find.byIcon(Icons.remove), findsNWidgets(3));
    expect(find.byIcon(Icons.add), findsNWidgets(3));
  });
}
