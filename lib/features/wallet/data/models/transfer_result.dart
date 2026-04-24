import 'package:equatable/equatable.dart';

class TransferResult extends Equatable {
  final String transactionId;
  final int points;
  final int newBalance;
  final String status;

  const TransferResult({
    required this.transactionId,
    required this.points,
    required this.newBalance,
    required this.status,
  });

  factory TransferResult.fromJson(Map<String, dynamic> json) => TransferResult(
        transactionId: json['transactionId'] as String,
        points: json['points'] as int,
        newBalance: json['newBalance'] as int,
        status: json['status'] as String,
      );

  Map<String, dynamic> toJson() => {
        'transactionId': transactionId,
        'points': points,
        'newBalance': newBalance,
        'status': status,
      };

  @override
  List<Object?> get props => [transactionId, points, newBalance, status];
}
