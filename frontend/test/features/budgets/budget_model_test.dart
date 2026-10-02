import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/budgets/models/budget.dart';

void main() {
  group('Budget Model', () {
    test('fromJson creates correct Budget object', () {
      final json = {
        'id': 1,
        'user_id': 2,
        'category_id': 3,
        'amount': 500.5,
        'month': 10,
        'year': 2023,
      };

      final budget = Budget.fromJson(json);

      expect(budget.id, 1);
      expect(budget.userId, 2);
      expect(budget.categoryId, 3);
      expect(budget.amount, 500.5);
      expect(budget.month, 10);
      expect(budget.year, 2023);
    });

    test('toJson creates correct Map', () {
      final budget = Budget(
        id: 1,
        userId: 2,
        categoryId: 3,
        amount: 500.5,
        month: 10,
        year: 2023,
      );

      final json = budget.toJson();

      expect(json['id'], 1);
      expect(json['user_id'], 2);
      expect(json['category_id'], 3);
      expect(json['amount'], 500.5);
      expect(json['month'], 10);
      expect(json['year'], 2023);
    });
  });
}
