class DashboardSummary {
  final double income;
  final double expenses;
  final double balance;
  final int transactionCount;

  DashboardSummary({
    required this.income,
    required this.expenses,
    required this.balance,
    required this.transactionCount,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      income: (json['income'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      transactionCount: json['transaction_count'] as int,
    );
  }
}

class CategorySpending {
  final int? categoryId;
  final String categoryName;
  final double amount;
  final double percentage;

  CategorySpending({
    this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  factory CategorySpending.fromJson(Map<String, dynamic> json) {
    return CategorySpending(
      categoryId: json['category_id'] as int?,
      categoryName: json['category_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class DashboardBudget {
  final double totalBudget;
  final double totalExpenses;
  final double remaining;
  final double percentageUsed;
  final bool isOverBudget;

  DashboardBudget({
    required this.totalBudget,
    required this.totalExpenses,
    required this.remaining,
    required this.percentageUsed,
    required this.isOverBudget,
  });

  factory DashboardBudget.fromJson(Map<String, dynamic> json) {
    return DashboardBudget(
      totalBudget: (json['total_budget'] as num).toDouble(),
      totalExpenses: (json['total_expenses'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
      percentageUsed: (json['percentage_used'] as num).toDouble(),
      isOverBudget: json['is_over_budget'] as bool,
    );
  }
}

class DashboardRecentTransaction {
  final int id;
  final int categoryId;
  final String categoryName;
  final String? description;
  final DateTime date;
  final double amount;
  final String transactionType;

  DashboardRecentTransaction({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    this.description,
    required this.date,
    required this.amount,
    required this.transactionType,
  });

  factory DashboardRecentTransaction.fromJson(Map<String, dynamic> json) {
    return DashboardRecentTransaction(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      categoryName: json['category_name'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      transactionType: json['transaction_type'] as String,
    );
  }
}

class DashboardInsight {
  final String type;
  final String? title;
  final String? description;

  DashboardInsight({
    required this.type,
    this.title,
    this.description,
  });

  factory DashboardInsight.fromJson(Map<String, dynamic> json) {
    return DashboardInsight(
      type: json['type'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );
  }
}

class DashboardResponse {
  final int month;
  final int year;
  final DashboardSummary summary;
  final List<CategorySpending> spendingByCategory;
  final DashboardBudget budget;
  final List<DashboardRecentTransaction> recentTransactions;
  final DashboardInsight insight;

  DashboardResponse({
    required this.month,
    required this.year,
    required this.summary,
    required this.spendingByCategory,
    required this.budget,
    required this.recentTransactions,
    required this.insight,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      month: json['month'] as int,
      year: json['year'] as int,
      summary: DashboardSummary.fromJson(json['summary'] as Map<String, dynamic>),
      spendingByCategory: (json['spending_by_category'] as List)
          .map((e) => CategorySpending.fromJson(e as Map<String, dynamic>))
          .toList(),
      budget: DashboardBudget.fromJson(json['budget'] as Map<String, dynamic>),
      recentTransactions: (json['recent_transactions'] as List)
          .map((e) => DashboardRecentTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      insight: DashboardInsight.fromJson(json['insight'] as Map<String, dynamic>),
    );
  }
}
