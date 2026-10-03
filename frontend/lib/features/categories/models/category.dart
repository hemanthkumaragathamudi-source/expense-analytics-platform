class Category {
  final int id;
  final String name;
  final String type; // 'INCOME' or 'EXPENSE'
  final int? userId;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.userId,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      userId: json['user_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // To check equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category &&
      other.id == id &&
      other.name == name &&
      other.type == type &&
      other.userId == userId &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      userId.hashCode ^
      createdAt.hashCode;
  }
}
