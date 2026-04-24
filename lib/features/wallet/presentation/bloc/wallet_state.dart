import 'package:equatable/equatable.dart';
import '../../data/models/points_balance.dart';
import '../../data/models/transaction.dart';
import '../../data/models/transfer_result.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletLoaded extends WalletState {
  final PointsBalance balance;
  final List<Transaction> allTransactions;
  final List<Transaction> filteredTransactions;
  final TransactionType? selectedFilter;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;

  const WalletLoaded({
    required this.balance,
    required this.allTransactions,
    required this.filteredTransactions,
    this.selectedFilter,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.currentPage = 1,
  });

  WalletLoaded copyWith({
    PointsBalance? balance,
    List<Transaction>? allTransactions,
    List<Transaction>? filteredTransactions,
    TransactionType? selectedFilter,
    bool clearFilter = false,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
  }) =>
      WalletLoaded(
        balance: balance ?? this.balance,
        allTransactions: allTransactions ?? this.allTransactions,
        filteredTransactions: filteredTransactions ?? this.filteredTransactions,
        selectedFilter: clearFilter ? null : (selectedFilter ?? this.selectedFilter),
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
      );

  @override
  List<Object?> get props => [
        balance,
        allTransactions,
        filteredTransactions,
        selectedFilter,
        isLoadingMore,
        hasMore,
        currentPage,
      ];
}

class WalletError extends WalletState {
  final String message;
  final String code;

  const WalletError(this.message, this.code);

  @override
  List<Object?> get props => [message, code];
}

class TransferLoading extends WalletState {
  const TransferLoading();
}

class TransferSuccess extends WalletState {
  final TransferResult result;
  const TransferSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class TransferError extends WalletState {
  final String message;
  final String code;

  const TransferError(this.message, this.code);

  @override
  List<Object?> get props => [message, code];
}
