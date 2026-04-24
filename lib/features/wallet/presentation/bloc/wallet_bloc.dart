import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/transaction.dart';
import '../../data/models/wallet_exception.dart';
import '../../data/repository/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _repository;
  static const int _pageLimit = 20;

  WalletBloc({required WalletRepository repository})
      : _repository = repository,
        super(const WalletInitial()) {
    on<LoadWallet>(_onLoadWallet);
    on<RefreshWallet>(_onRefreshWallet);
    on<FilterTransactions>(_onFilterTransactions);
    on<LoadMoreTransactions>(_onLoadMoreTransactions);
    on<TransferPoints>(_onTransferPoints);
  }

  Future<void> _onLoadWallet(LoadWallet event, Emitter<WalletState> emit) async {
    emit(const WalletLoading());
    await _fetchInitial(emit);
  }

  Future<void> _onRefreshWallet(RefreshWallet event, Emitter<WalletState> emit) async {
    await _fetchInitial(emit);
  }

  Future<void> _fetchInitial(Emitter<WalletState> emit) async {
    try {
      final balance = await _repository.getBalance();
      final page = await _repository.getTransactions(page: 1, limit: _pageLimit);
      emit(WalletLoaded(
        balance: balance,
        allTransactions: page.transactions,
        filteredTransactions: page.transactions,
        selectedFilter: null,
        isLoadingMore: false,
        hasMore: page.hasNext,
        currentPage: 1,
      ));
    } on WalletException catch (e) {
      emit(WalletError(e.message, e.code));
    } catch (e) {
      emit(WalletError(e.toString(), 'UNKNOWN'));
    }
  }

  void _onFilterTransactions(FilterTransactions event, Emitter<WalletState> emit) {
    final current = state;
    if (current is! WalletLoaded) return;

    final type = event.type;
    final filtered = type == null
        ? List<Transaction>.from(current.allTransactions)
        : current.allTransactions.where((t) => t.type == type).toList();

    emit(current.copyWith(
      filteredTransactions: filtered,
      selectedFilter: type,
      clearFilter: type == null,
    ));
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactions event,
    Emitter<WalletState> emit,
  ) async {
    final current = state;
    if (current is! WalletLoaded) return;
    if (current.isLoadingMore || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.currentPage + 1;
      final page = await _repository.getTransactions(
        page: nextPage,
        limit: _pageLimit,
      );
      final newAll = [...current.allTransactions, ...page.transactions];
      final filter = current.selectedFilter;
      final newFiltered = filter == null
          ? List<Transaction>.from(newAll)
          : newAll.where((t) => t.type == filter).toList();

      emit(current.copyWith(
        allTransactions: newAll,
        filteredTransactions: newFiltered,
        isLoadingMore: false,
        hasMore: page.hasNext,
        currentPage: nextPage,
      ));
    } on WalletException catch (e) {
      emit(current.copyWith(isLoadingMore: false));
      emit(WalletError(e.message, e.code));
    } catch (e) {
      emit(current.copyWith(isLoadingMore: false));
      emit(WalletError(e.toString(), 'UNKNOWN'));
    }
  }

  Future<void> _onTransferPoints(TransferPoints event, Emitter<WalletState> emit) async {
    final previous = state;
    emit(const TransferLoading());
    try {
      final result = await _repository.transferPoints(event.request);
      emit(TransferSuccess(result));
      if (previous is WalletLoaded) {
        emit(previous.copyWith(
          balance: previous.balance.copyWith(totalPoints: result.newBalance),
        ));
      }
    } on WalletException catch (e) {
      emit(TransferError(e.message, e.code));
      if (previous is WalletLoaded) emit(previous);
    } catch (e) {
      emit(TransferError(e.toString(), 'UNKNOWN'));
      if (previous is WalletLoaded) emit(previous);
    }
  }
}
