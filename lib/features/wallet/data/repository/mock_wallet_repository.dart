import '../models/merchant_balance.dart';
import '../models/paginated_transactions.dart';
import '../models/points_balance.dart';
import '../models/transaction.dart';
import '../models/transfer_request.dart';
import '../models/transfer_result.dart';
import '../models/wallet_exception.dart';
import 'wallet_repository.dart';

class MockWalletRepository implements WalletRepository {
  static const int _currentTotalPoints = 15750;

  final _merchants = const [
    MerchantBalance(
      merchantId: 'merchant_techmart',
      merchantName: 'TechMart',
      merchantLogo: 'https://picsum.photos/seed/techmart/100',
      points: 8500,
      tier: 'Gold',
    ),
    MerchantBalance(
      merchantId: 'merchant_foodmart',
      merchantName: 'FoodMart',
      merchantLogo: 'https://picsum.photos/seed/foodmart/100',
      points: 4250,
      tier: 'Silver',
    ),
    MerchantBalance(
      merchantId: 'merchant_stylehub',
      merchantName: 'StyleHub',
      merchantLogo: 'https://picsum.photos/seed/stylehub/100',
      points: 3000,
      tier: 'Bronze',
    ),
  ];

  late final List<Transaction> _allTransactions = [
    Transaction(
      id: 'txn_001',
      type: TransactionType.EARN,
      points: 500,
      description: 'Earned at TechMart',
      merchantName: 'TechMart',
      merchantLogo: 'https://picsum.photos/seed/techmart/100',
      createdAt: DateTime.parse('2024-02-15T12:00:00Z'),
      status: TransactionStatus.COMPLETED,
    ),
    Transaction(
      id: 'txn_002',
      type: TransactionType.REDEEM,
      points: 1000,
      description: 'Redeemed at FoodMart',
      merchantName: 'FoodMart',
      merchantLogo: 'https://picsum.photos/seed/foodmart/100',
      createdAt: DateTime.parse('2024-02-14T12:00:00Z'),
      status: TransactionStatus.COMPLETED,
    ),
    Transaction(
      id: 'txn_003',
      type: TransactionType.TRANSFER_OUT,
      points: 250,
      description: 'Transfer sent',
      merchantName: null,
      merchantLogo: null,
      createdAt: DateTime.parse('2024-02-13T12:00:00Z'),
      status: TransactionStatus.COMPLETED,
    ),
    Transaction(
      id: 'txn_004',
      type: TransactionType.PURCHASE,
      points: 750,
      description: 'Purchase at StyleHub',
      merchantName: 'StyleHub',
      merchantLogo: 'https://picsum.photos/seed/stylehub/100',
      createdAt: DateTime.parse('2024-02-12T12:00:00Z'),
      status: TransactionStatus.COMPLETED,
    ),
    Transaction(
      id: 'txn_005',
      type: TransactionType.TRANSFER_IN,
      points: 300,
      description: 'Transfer received',
      merchantName: null,
      merchantLogo: null,
      createdAt: DateTime.parse('2024-02-08T12:00:00Z'),
      status: TransactionStatus.PENDING,
    ),
  ];

  @override
  Future<PointsBalance> getBalance() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return PointsBalance(
      totalPoints: _currentTotalPoints,
      pendingPoints: 500,
      expiringPoints: 1200,
      expiringDate: DateTime.parse('2024-03-31T23:59:59Z'),
      lastUpdated: DateTime.parse('2024-02-15T10:30:00Z'),
      balancesByMerchant: _merchants,
    );
  }

  @override
  Future<PaginatedTransactions> getTransactions({
    int page = 1,
    int limit = 20,
    TransactionType? type,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final filtered = type == null
        ? List<Transaction>.from(_allTransactions)
        : _allTransactions.where((t) => t.type == type).toList();

    final start = (page - 1) * limit;
    if (start >= filtered.length) {
      return PaginatedTransactions(
        transactions: const [],
        page: page,
        totalItems: filtered.length,
        hasNext: false,
      );
    }
    final end = (start + limit).clamp(0, filtered.length);
    final slice = filtered.sublist(start, end);

    return PaginatedTransactions(
      transactions: slice,
      page: page,
      totalItems: filtered.length,
      hasNext: end < filtered.length,
    );
  }

  @override
  Future<TransferResult> transferPoints(TransferRequest request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.points > _currentTotalPoints) {
      throw const WalletException(
        'INSUFFICIENT_BALANCE',
        "You don't have enough points",
      );
    }
    if (request.recipient == 'notfound@test.com') {
      throw const WalletException(
        'RECIPIENT_NOT_FOUND',
        'Recipient not found',
      );
    }

    return TransferResult(
      transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      points: request.points,
      newBalance: _currentTotalPoints - request.points,
      status: 'COMPLETED',
    );
  }
}
