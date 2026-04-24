import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopplus_wallet/features/wallet/data/models/merchant_balance.dart';
import 'package:shopplus_wallet/features/wallet/data/models/paginated_transactions.dart';
import 'package:shopplus_wallet/features/wallet/data/models/points_balance.dart';
import 'package:shopplus_wallet/features/wallet/data/models/transaction.dart';
import 'package:shopplus_wallet/features/wallet/data/models/wallet_exception.dart';
import 'package:shopplus_wallet/features/wallet/data/repository/wallet_repository.dart';
import 'package:shopplus_wallet/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:shopplus_wallet/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:shopplus_wallet/features/wallet/presentation/bloc/wallet_state.dart';

class _MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late _MockWalletRepository repository;

  final testBalance = PointsBalance(
    totalPoints: 15750,
    pendingPoints: 500,
    expiringPoints: 1200,
    expiringDate: DateTime.parse('2024-03-31T23:59:59Z'),
    lastUpdated: DateTime.parse('2024-02-15T10:30:00Z'),
    balancesByMerchant: const [
      MerchantBalance(
        merchantId: 'm1',
        merchantName: 'TechMart',
        merchantLogo: 'https://example.com/tm.png',
        points: 8500,
        tier: 'Gold',
      ),
    ],
  );

  final earnTx = Transaction(
    id: 'txn_001',
    type: TransactionType.EARN,
    points: 500,
    description: 'Earn',
    merchantName: 'TechMart',
    merchantLogo: null,
    createdAt: DateTime.parse('2024-02-15T12:00:00Z'),
    status: TransactionStatus.COMPLETED,
  );

  final redeemTx = Transaction(
    id: 'txn_002',
    type: TransactionType.REDEEM,
    points: 1000,
    description: 'Redeem',
    merchantName: 'FoodMart',
    merchantLogo: null,
    createdAt: DateTime.parse('2024-02-14T12:00:00Z'),
    status: TransactionStatus.COMPLETED,
  );

  final transferTx = Transaction(
    id: 'txn_003',
    type: TransactionType.TRANSFER_OUT,
    points: 250,
    description: 'Transfer',
    merchantName: null,
    merchantLogo: null,
    createdAt: DateTime.parse('2024-02-13T12:00:00Z'),
    status: TransactionStatus.COMPLETED,
  );

  final allTxs = [earnTx, redeemTx, transferTx];

  final firstPage = PaginatedTransactions(
    transactions: allTxs,
    page: 1,
    totalItems: 3,
    hasNext: false,
  );

  WalletBloc buildBloc() => WalletBloc(repository: repository);

  void stubHappyPath() {
    when(() => repository.getBalance()).thenAnswer((_) async => testBalance);
    when(() => repository.getTransactions(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          type: any(named: 'type'),
        )).thenAnswer((_) async => firstPage);
  }

  setUp(() {
    repository = _MockWalletRepository();
  });

  test('initial state is WalletInitial', () {
    stubHappyPath();
    expect(buildBloc().state, const WalletInitial());
  });

  blocTest<WalletBloc, WalletState>(
    'LoadWallet emits [WalletLoading, WalletLoaded] with correct balance and transactions',
    setUp: stubHappyPath,
    build: buildBloc,
    act: (bloc) => bloc.add(const LoadWallet()),
    expect: () => [
      const WalletLoading(),
      WalletLoaded(
        balance: testBalance,
        allTransactions: allTxs,
        filteredTransactions: allTxs,
        selectedFilter: null,
        isLoadingMore: false,
        hasMore: false,
        currentPage: 1,
      ),
    ],
  );

  blocTest<WalletBloc, WalletState>(
    'FilterTransactions(EARN) returns only EARN in filteredTransactions',
    setUp: stubHappyPath,
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const LoadWallet());
      await Future.delayed(const Duration(milliseconds: 10));
      bloc.add(const FilterTransactions(TransactionType.EARN));
    },
    skip: 2,
    verify: (bloc) {
      final state = bloc.state as WalletLoaded;
      expect(state.filteredTransactions, [earnTx]);
      expect(state.selectedFilter, TransactionType.EARN);
      expect(state.allTransactions, allTxs);
    },
  );

  blocTest<WalletBloc, WalletState>(
    'FilterTransactions(null) restores full allTransactions in filteredTransactions',
    setUp: stubHappyPath,
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const LoadWallet());
      await Future.delayed(const Duration(milliseconds: 10));
      bloc.add(const FilterTransactions(TransactionType.EARN));
      bloc.add(const FilterTransactions(null));
    },
    verify: (bloc) {
      final state = bloc.state as WalletLoaded;
      expect(state.filteredTransactions, allTxs);
      expect(state.selectedFilter, isNull);
    },
  );

  blocTest<WalletBloc, WalletState>(
    'FilterTransactions does NOT overwrite allTransactions',
    setUp: stubHappyPath,
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const LoadWallet());
      await Future.delayed(const Duration(milliseconds: 10));
      bloc.add(const FilterTransactions(TransactionType.REDEEM));
    },
    verify: (bloc) {
      final state = bloc.state as WalletLoaded;
      expect(state.allTransactions, allTxs);
      expect(state.filteredTransactions, [redeemTx]);
    },
  );

  blocTest<WalletBloc, WalletState>(
    'RefreshWallet reloads and resets to page 1',
    setUp: stubHappyPath,
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const LoadWallet());
      await Future.delayed(const Duration(milliseconds: 10));
      bloc.add(const RefreshWallet());
    },
    verify: (bloc) {
      final state = bloc.state as WalletLoaded;
      expect(state.currentPage, 1);
      verify(() => repository.getBalance()).called(2);
    },
  );

  blocTest<WalletBloc, WalletState>(
    'LoadWallet emits [WalletLoading, WalletError] when repository throws',
    setUp: () {
      when(() => repository.getBalance()).thenThrow(
        const WalletException('SERVER_ERROR', 'Server down'),
      );
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const LoadWallet()),
    expect: () => [
      const WalletLoading(),
      const WalletError('Server down', 'SERVER_ERROR'),
    ],
  );
}
