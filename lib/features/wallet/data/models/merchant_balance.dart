import 'package:equatable/equatable.dart';

class MerchantBalance extends Equatable {
  final String merchantId;
  final String merchantName;
  final String merchantLogo;
  final int points;
  final String tier;

  const MerchantBalance({
    required this.merchantId,
    required this.merchantName,
    required this.merchantLogo,
    required this.points,
    required this.tier,
  });

  factory MerchantBalance.fromJson(Map<String, dynamic> json) => MerchantBalance(
        merchantId: json['merchantId'] as String,
        merchantName: json['merchantName'] as String,
        merchantLogo: json['merchantLogo'] as String,
        points: json['points'] as int,
        tier: json['tier'] as String,
      );

  Map<String, dynamic> toJson() => {
        'merchantId': merchantId,
        'merchantName': merchantName,
        'merchantLogo': merchantLogo,
        'points': points,
        'tier': tier,
      };

  MerchantBalance copyWith({
    String? merchantId,
    String? merchantName,
    String? merchantLogo,
    int? points,
    String? tier,
  }) =>
      MerchantBalance(
        merchantId: merchantId ?? this.merchantId,
        merchantName: merchantName ?? this.merchantName,
        merchantLogo: merchantLogo ?? this.merchantLogo,
        points: points ?? this.points,
        tier: tier ?? this.tier,
      );

  @override
  List<Object?> get props => [merchantId, merchantName, merchantLogo, points, tier];
}
