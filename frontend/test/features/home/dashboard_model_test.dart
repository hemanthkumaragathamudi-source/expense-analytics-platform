import 'package:flutter_test/flutter_test.dart';
import 'package:etracker/features/home/models/dashboard.dart';

void main() {
  group('DashboardResponse Model parsing', () {
    final Map<String, dynamic> mockJson = {
      "month": 10,
      "year": 2023,
      "summary": {
        "income": 5000.0,
        "expenses": 2000.0,
        "balance": 3000.0,
        "transaction_count": 10
      },
      "spending_by_category": [
        {
          "category_id": 1,
          "category_name": "Groceries",
          "amount": 500.0,
          "percentage": 25.0
        }
      ],
      "budget": {
        "total_budget": 3000.0,
        "total_expenses": 2000.0,
        "remaining": 1000.0,
        "percentage_used": 66.6,
        "is_over_budget": false
      },
      "recent_transactions": [
        {
          "id": 1,
          "category_id": 1,
          "category_name": "Groceries",
          "description": "Walmart",
          "date": "2023-10-05T00:00:00",
          "amount": 50.0,
          "transaction_type": "EXPENSE"
        }
      ],
      "insight": {
        "type": "savings",
        "title": "Good job",
        "description": "You saved this month."
      }
    };

    test('should parse valid JSON correctly', () {
      final response = DashboardResponse.fromJson(mockJson);

      expect(response.month, 10);
      expect(response.year, 2023);

      expect(response.summary.balance, 3000.0);
      expect(response.summary.transactionCount, 10);

      expect(response.spendingByCategory.length, 1);
      expect(response.spendingByCategory[0].categoryName, "Groceries");
      expect(response.spendingByCategory[0].amount, 500.0);

      expect(response.budget.totalBudget, 3000.0);
      expect(response.budget.isOverBudget, false);

      expect(response.recentTransactions.length, 1);
      expect(response.recentTransactions[0].description, "Walmart");
      expect(response.recentTransactions[0].amount, 50.0);

      expect(response.insight.type, "savings");
      expect(response.insight.description, "You saved this month.");
    });
  });
}
