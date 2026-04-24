import 'package:equatable/equatable.dart';
import 'merchant_balance.dart';

class PointsBalance extends Equatable {
  final int totalPoints;
  final int pendingPoints;
  final int expiringPoints;
  final DateTime expiringDate;
  final DateTime lastUpdated;
  final List<MerchantBalance> balancesByMerchant;

  const PointsBalance({
    required this.totalPoints,
    required this.pendingPoints,
    required this.expiringPoints,
    required this.expiringDate,
    required this.lastUpdated,
    required this.balancesByMerchant,
  });

  factory PointsBalance.fromJson(Map<String, dynamic> json) => PointsBalance(
        totalPoints: json['totalPoints'] as int,
        pendingPoints: json['pendingPoints'] as int,
        expiringPoints: json['expiringPoints'] as int,
        expiringDate: DateTime.parse(json['expiringDate'] as String),
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
        balancesByMerchant: (json['balancesByMerchant'] as List<dynamic>)
            .map((e) => MerchantBalance.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'totalPoints': totalPoints,
        'pendingPoints': pendingPoints,
        'expiringPoints': expiringPoints,
        'expiringDate': expiringDate.toIso8601String(),
        'lastUpdated': lastUpdated.toIso8601String(),
        'balancesByMerchant': balancesByMerchant.map((m) => m.toJson()).toList(),
      };

  PointsBalance copyWith({
    int? totalPoints,
    int? pendingPoints,
    int? expiringPoints,
    DateTime? expiringDate,
    DateTime? lastUpdated,
    List<MerchantBalance>? balancesByMerchant,
  }) =>
      PointsBalance(
        totalPoints: totalPoints ?? this.totalPoints,
        pendingPoints: pendingPoints ?? this.pendingPoints,
        expiringPoints: expiringPoints ?? this.expiringPoints,
        expiringDate: expiringDate ?? this.expiringDate,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        balancesByMerchant: balancesByMerchant ?? this.balancesByMerchant,
      );

  @override
  List<Object?> get props => [
        totalPoints,
        pendingPoints,
        expiringPoints,
        expiringDate,
        lastUpdated,
        balancesByMerchant,
      ];
}
