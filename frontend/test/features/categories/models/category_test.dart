import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/categories/models/category.dart';

void main() {
  group('Category Model', () {
    test('fromJson creates correct Category object', () {
      final json = {
        'id': 1,
        'name': 'Groceries',
        'type': 'EXPENSE',
        'user_id': 2,
        'created_at': '2023-01-01T10:00:00.000Z',
      };

      final category = Category.fromJson(json);

      expect(category.id, 1);
      expect(category.name, 'Groceries');
      expect(category.type, 'EXPENSE');
      expect(category.userId, 2);
      expect(category.createdAt, DateTime.utc(2023, 1, 1, 10));
    });

    test('toJson creates correct Map', () {
      final category = Category(
        id: 1,
        name: 'Salary',
        type: 'INCOME',
        userId: null,
        createdAt: DateTime.utc(2023, 1, 1, 10),
      );

      final json = category.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Salary');
      expect(json['type'], 'INCOME');
      expect(json['user_id'], null);
      expect(json['created_at'], '2023-01-01T10:00:00.000Z');
    });

    test('equality and hashcode', () {
      final category1 = Category(
        id: 1,
        name: 'Groceries',
        type: 'EXPENSE',
        userId: 2,
        createdAt: DateTime.utc(2023, 1, 1, 10),
      );

      final category2 = Category(
        id: 1,
        name: 'Groceries',
        type: 'EXPENSE',
        userId: 2,
        createdAt: DateTime.utc(2023, 1, 1, 10),
      );

      final category3 = Category(
        id: 2,
        name: 'Rent',
        type: 'EXPENSE',
        userId: 2,
        createdAt: DateTime.utc(2023, 1, 1, 10),
      );

      expect(category1, category2);
      expect(category1.hashCode, category2.hashCode);
      expect(category1, isNot(category3));
    });
  });
}
