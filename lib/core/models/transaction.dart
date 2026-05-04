class Transaction {
  final DateTime time;
  final int amount;
  final String imageUrl;
  final List<String> tags;
  final String note;
  final String location;
  final bool type;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Transaction({
    required this.time,
    required this.amount,
    required this.imageUrl,
    this.tags = const [],
    this.note = '',
    this.location = '',
    this.type = false,
    this.source = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      time: DateTime.parse(json['time'] as String),
      amount: json['amount'] as int,
      imageUrl: json['imageUrl'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      note: json['note'] as String? ?? '',
      location: json['location'] as String? ?? '',
      type: json['type'] as bool? ?? false,
      source: json['source'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'amount': amount,
      'imageUrl': imageUrl,
      'tags': tags,
      'note': note,
      'location': location,
      'type': type,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}
