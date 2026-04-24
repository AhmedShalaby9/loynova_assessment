import 'package:equatable/equatable.dart';
import 'transaction.dart';

class PaginatedTransactions extends Equatable {
  final List<Transaction> transactions;
  final int page;
  final int totalItems;
  final bool hasNext;

  const PaginatedTransactions({
    required this.transactions,
    required this.page,
    required this.totalItems,
    required this.hasNext,
  });

  factory PaginatedTransactions.fromJson(Map<String, dynamic> json) => PaginatedTransactions(
        transactions: (json['transactions'] as List<dynamic>)
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList(),
        page: json['page'] as int,
        totalItems: json['totalItems'] as int,
        hasNext: json['hasNext'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'page': page,
        'totalItems': totalItems,
        'hasNext': hasNext,
      };

  @override
  List<Object?> get props => [transactions, page, totalItems, hasNext];
}
