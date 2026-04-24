import 'package:equatable/equatable.dart';

enum TransactionType { EARN, REDEEM, TRANSFER_IN, TRANSFER_OUT, PURCHASE }

enum TransactionStatus { COMPLETED, PENDING, FAILED }

TransactionType _parseType(String value) => TransactionType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => TransactionType.EARN,
    );

TransactionStatus _parseStatus(String value) => TransactionStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => TransactionStatus.PENDING,
    );

class Transaction extends Equatable {
  final String id;
  final TransactionType type;
  final int points;
  final String description;
  final String? merchantName;
  final String? merchantLogo;
  final DateTime createdAt;
  final TransactionStatus status;

  const Transaction({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    this.merchantName,
    this.merchantLogo,
    required this.createdAt,
    required this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        type: _parseType(json['type'] as String),
        points: json['points'] as int,
        description: json['description'] as String,
        merchantName: json['merchantName'] as String?,
        merchantLogo: json['merchantLogo'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: _parseStatus(json['status'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'points': points,
        'description': description,
        'merchantName': merchantName,
        'merchantLogo': merchantLogo,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
      };

  Transaction copyWith({
    String? id,
    TransactionType? type,
    int? points,
    String? description,
    String? merchantName,
    String? merchantLogo,
    DateTime? createdAt,
    TransactionStatus? status,
  }) =>
      Transaction(
        id: id ?? this.id,
        type: type ?? this.type,
        points: points ?? this.points,
        description: description ?? this.description,
        merchantName: merchantName ?? this.merchantName,
        merchantLogo: merchantLogo ?? this.merchantLogo,
        createdAt: createdAt ?? this.createdAt,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props =>
      [id, type, points, description, merchantName, merchantLogo, createdAt, status];
}
