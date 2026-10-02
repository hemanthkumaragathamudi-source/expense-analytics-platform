import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/transactions/models/transaction.dart';

void main() {
  group('Transaction Model', () {
    test('should parse from JSON correctly', () {
      final json = {
        'id': 1,
        'user_id': 10,
        'date': '2023-10-01',
        'category_id': 2,
        'description': 'Coffee',
        'amount': 4.5,
        'transaction_type': 'EXPENSE',
        'payment_method_id': 3,
        'notes': 'Morning coffee',
        'created_at': '2023-10-01T08:00:00Z',
        'updated_at': '2023-10-01T08:00:00Z',
      };

      final transaction = Transaction.fromJson(json);

      expect(transaction.id, 1);
      expect(transaction.userId, 10);
      expect(transaction.date, DateTime.parse('2023-10-01'));
      expect(transaction.categoryId, 2);
      expect(transaction.description, 'Coffee');
      expect(transaction.amount, 4.5);
      expect(transaction.transactionType, 'EXPENSE');
      expect(transaction.paymentMethodId, 3);
      expect(transaction.notes, 'Morning coffee');
      expect(transaction.createdAt, DateTime.parse('2023-10-01T08:00:00Z'));
      expect(transaction.updatedAt, DateTime.parse('2023-10-01T08:00:00Z'));
    });

    test('should serialize to JSON correctly', () {
      final transaction = Transaction(
        id: 1,
        userId: 10,
        date: DateTime(2023, 10, 1),
        categoryId: 2,
        description: 'Coffee',
        amount: 4.5,
        transactionType: 'EXPENSE',
        paymentMethodId: 3,
        notes: 'Morning coffee',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final json = transaction.toJson();

      expect(json['date'], '2023-10-01');
      expect(json['category_id'], 2);
      expect(json['description'], 'Coffee');
      expect(json['amount'], 4.5);
      expect(json['transaction_type'], 'EXPENSE');
      expect(json['payment_method_id'], 3);
      expect(json['notes'], 'Morning coffee');
      expect(json.containsKey('id'), false);
    });
  });
}
