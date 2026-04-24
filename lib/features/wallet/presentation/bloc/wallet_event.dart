import 'package:equatable/equatable.dart';
import '../../data/models/transaction.dart';
import '../../data/models/transfer_request.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWallet extends WalletEvent {
  const LoadWallet();
}

class RefreshWallet extends WalletEvent {
  const RefreshWallet();
}

class FilterTransactions extends WalletEvent {
  final TransactionType? type;
  const FilterTransactions(this.type);

  @override
  List<Object?> get props => [type];
}

class LoadMoreTransactions extends WalletEvent {
  const LoadMoreTransactions();
}

class TransferPoints extends WalletEvent {
  final TransferRequest request;
  const TransferPoints(this.request);

  @override
  List<Object?> get props => [request];
}
