class Transaction {
  final int id;
  final int userId;
  final DateTime date;
  final int categoryId;
  final String? description;
  final double amount;
  final String transactionType;
  final int? paymentMethodId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.date,
    required this.categoryId,
    this.description,
    required this.amount,
    required this.transactionType,
    this.paymentMethodId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      date: DateTime.parse(json['date'] as String),
      categoryId: json['category_id'] as int,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      transactionType: json['transaction_type'] as String,
      paymentMethodId: json['payment_method_id'] as int?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      'category_id': categoryId,
      if (description != null) 'description': description,
      'amount': amount,
      'transaction_type': transactionType,
      if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      if (notes != null) 'notes': notes,
    };
  }
}
