import 'package:flutter_test/flutter_test.dart';
import '../lib/counter.dart';

// Unit Testing

void main() {
  group("Counter Logic", () {
    test("To check increment method", () {
      Counter c1 = Counter();

      c1.increment(); // 1

      expect(c1.counter, 1);
    });

    test("To check decrement method", () {
      Counter c1 = Counter();

      c1.decrement(); // -1

      expect(c1.counter, -1);
    });
  });
}
