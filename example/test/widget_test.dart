// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';
import '../lib/stores.dart';

const kMessage = 'A message';
const kName = 'Bob';

void main() {
  testWidgets('sended messages appear', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(new MaterialApp(
        title: 'Chat',
        theme: new ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.orangeAccent[400]),
        home: new ChatScreen()));

    expect(find.byKey(const Key('msgField')), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byKey(const Key('msgField')), kMessage);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    expect(find.text(kMessage), findsOneWidget);
    expect(find.byType(ChatMessageListItem), findsOneWidget);

    await tester.enterText(find.byKey(const Key('msgField')), kMessage);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    expect(find.text(kMessage), findsNWidgets(2));
    expect(find.byType(ChatMessageListItem), findsNWidgets(2));
  });

  testWidgets('fill a ChatMessageItem', (WidgetTester tester) async {
    Widget widget = new Material(
        child: new ChatMessageListItem(new ChatMessage(
            text: kMessage,
            sender: new ChatUser(name: kName, color: Colors.yellow))));
    await tester.pumpWidget(widget);
    expect(find.text(kName), findsOneWidget);
    expect(find.text(kMessage), findsOneWidget);
  });
}
