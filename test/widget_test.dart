import 'package:firebase_learning_app/views/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("Counter Testing", (WidgetTester tester) async {
    // Step - 1: load the widget => pumpWidget()
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(),
      ),
    );

    // Step - 2: create the finder => find.text(), find.byType(), .....
    var textFinder = find.text("0");

    // Step - 3: set the expectation => expect()
    expect(textFinder, findsOneWidget);

    // Step - 4: do the preferred operations such as tapping the button, etc...
    var buttonFinder = find.byType(ElevatedButton);
    await tester.tap(buttonFinder);

    // Step - 5: refresh/rebuild the UI => pump()
    await tester.pump();

    // Step - 6: Repeat from the Step - 2 onwards
    var updatedTextFinder = find.text("1");
    expect(updatedTextFinder, findsOneWidget);
  });
}
