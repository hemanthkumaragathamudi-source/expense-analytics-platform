import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/payment_methods/models/payment_method.dart';

void main() {
  group('PaymentMethod Model', () {
    const paymentMethod = PaymentMethod(
      id: 1,
      name: 'Cash',
    );

    test('should support value equality', () {
      expect(
        const PaymentMethod(id: 1, name: 'Cash'),
        equals(paymentMethod),
      );
    });

    test('fromJson should parse valid JSON correctly', () {
      final json = {
        'id': 1,
        'name': 'Cash',
      };

      final result = PaymentMethod.fromJson(json);

      expect(result, equals(paymentMethod));
    });

    test('toJson should convert to valid JSON', () {
      final result = paymentMethod.toJson();

      expect(result, equals({
        'id': 1,
        'name': 'Cash',
      }));
    });
  });
}
