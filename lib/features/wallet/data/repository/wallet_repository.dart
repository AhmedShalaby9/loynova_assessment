import '../models/paginated_transactions.dart';
import '../models/points_balance.dart';
import '../models/transaction.dart';
import '../models/transfer_request.dart';
import '../models/transfer_result.dart';

abstract class WalletRepository {
  Future<PointsBalance> getBalance();

  Future<PaginatedTransactions> getTransactions({
    int page = 1,
    int limit = 20,
    TransactionType? type,
  });

  Future<TransferResult> transferPoints(TransferRequest request);
}
