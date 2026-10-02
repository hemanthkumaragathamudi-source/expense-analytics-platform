class Category {
  final int id;
  final String name;
  final String type;
  final int? userId;
  final DateTime createdAt;

  Category({
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
      if (userId != null) 'user_id': userId,
    };
  }
}
