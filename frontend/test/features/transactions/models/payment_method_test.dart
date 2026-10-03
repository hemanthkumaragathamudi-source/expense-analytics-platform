import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/transactions/models/payment_method.dart';

void main() {
  group('PaymentMethod Model', () {
    test('should parse from JSON correctly', () {
      final json = {
        'id': 1,
        'name': 'Cash',
      };

      final paymentMethod = PaymentMethod.fromJson(json);

      expect(paymentMethod.id, 1);
      expect(paymentMethod.name, 'Cash');
    });

    test('should serialize to JSON correctly', () {
      final paymentMethod = PaymentMethod(
        id: 1,
        name: 'Cash',
      );

      final json = paymentMethod.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Cash');
    });
  });
}
