import 'package:flutter_test/flutter_test.dart';

import 'package:breakout_room_activity/main.dart';

void main() {
  testWidgets('Todo app builds', (WidgetTester tester) async {
    await tester.pumpWidget(TodoApp());
    expect(find.text('Firestore Todo App'), findsOneWidget);
  });
}
