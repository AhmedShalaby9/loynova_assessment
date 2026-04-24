import 'package:flutter_test/flutter_test.dart';
import 'package:shopplus_wallet/features/wallet/data/models/transaction.dart';
import 'package:shopplus_wallet/features/wallet/data/models/transfer_request.dart';
import 'package:shopplus_wallet/features/wallet/data/models/wallet_exception.dart';
import 'package:shopplus_wallet/features/wallet/data/repository/mock_wallet_repository.dart';

void main() {
  late MockWalletRepository repository;

  setUp(() {
    repository = MockWalletRepository();
  });

  group('MockWalletRepository.getBalance', () {
    test('returns PointsBalance with totalPoints 15750', () async {
      final balance = await repository.getBalance();
      expect(balance.totalPoints, 15750);
      expect(balance.pendingPoints, 500);
      expect(balance.expiringPoints, 1200);
      expect(balance.balancesByMerchant.length, 3);
    });
  });

  group('MockWalletRepository.getTransactions', () {
    test('returns first page with correct items', () async {
      final page = await repository.getTransactions(page: 1, limit: 20);
      expect(page.page, 1);
      expect(page.transactions.length, 5);
      expect(page.totalItems, 5);
      expect(page.hasNext, isFalse);
      expect(page.transactions.first.id, 'txn_001');
    });

    test('filters transactions by type EARN', () async {
      final page = await repository.getTransactions(type: TransactionType.EARN);
      expect(page.transactions.length, 1);
      expect(page.transactions.every((t) => t.type == TransactionType.EARN), isTrue);
      expect(page.transactions.first.id, 'txn_001');
    });

    test('filters transactions by type REDEEM', () async {
      final page =
          await repository.getTransactions(type: TransactionType.REDEEM);
      expect(page.transactions.length, 1);
      expect(page.transactions.first.id, 'txn_002');
    });

    test('pagination returns correct page slice', () async {
      final first = await repository.getTransactions(page: 1, limit: 2);
      expect(first.transactions.length, 2);
      expect(first.transactions[0].id, 'txn_001');
      expect(first.transactions[1].id, 'txn_002');
      expect(first.hasNext, isTrue);

      final second = await repository.getTransactions(page: 2, limit: 2);
      expect(second.transactions.length, 2);
      expect(second.transactions[0].id, 'txn_003');
      expect(second.transactions[1].id, 'txn_004');
      expect(second.hasNext, isTrue);

      final third = await repository.getTransactions(page: 3, limit: 2);
      expect(third.transactions.length, 1);
      expect(third.transactions[0].id, 'txn_005');
      expect(third.hasNext, isFalse);
    });

    test('returns empty list for out-of-range page', () async {
      final page = await repository.getTransactions(page: 99, limit: 20);
      expect(page.transactions, isEmpty);
      expect(page.hasNext, isFalse);
    });
  });

  group('MockWalletRepository.transferPoints', () {
    test('success returns TransferResult with correct newBalance', () async {
      const request = TransferRequest(
        recipient: 'recipient@test.com',
        points: 500,
      );
      final result = await repository.transferPoints(request);
      expect(result.points, 500);
      expect(result.newBalance, 15750 - 500);
      expect(result.status, 'COMPLETED');
      expect(result.transactionId, startsWith('txn_'));
    });

    test('throws INSUFFICIENT_BALANCE when points > 15750', () async {
      const request = TransferRequest(
        recipient: 'recipient@test.com',
        points: 20000,
      );
      await expectLater(
        repository.transferPoints(request),
        throwsA(isA<WalletException>()
            .having((e) => e.code, 'code', 'INSUFFICIENT_BALANCE')),
      );
    });

    test('throws RECIPIENT_NOT_FOUND for notfound@test.com', () async {
      const request = TransferRequest(
        recipient: 'notfound@test.com',
        points: 100,
      );
      await expectLater(
        repository.transferPoints(request),
        throwsA(isA<WalletException>()
            .having((e) => e.code, 'code', 'RECIPIENT_NOT_FOUND')),
      );
    });
  });
}
