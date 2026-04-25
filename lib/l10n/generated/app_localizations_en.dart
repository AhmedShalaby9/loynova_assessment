// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ShopPlus Wallet';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get pendingPoints => 'Pending';

  @override
  String get expiringPoints => 'Expiring';

  @override
  String get transferButton => 'Transfer Points';

  @override
  String get filterAll => 'All';

  @override
  String get filterEarn => 'Earn';

  @override
  String get filterRedeem => 'Redeem';

  @override
  String get filterTransfer => 'Transfer';

  @override
  String get transactionEarn => 'Earned';

  @override
  String get transactionRedeem => 'Redeemed';

  @override
  String get transactionTransferIn => 'Received';

  @override
  String get transactionTransferOut => 'Sent';

  @override
  String get transactionPurchase => 'Purchase';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusFailed => 'Failed';

  @override
  String get retryButton => 'Retry';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get emptyTransactions => 'No transactions found';

  @override
  String get transferTitle => 'Transfer Points';

  @override
  String get recipientLabel => 'Recipient (Phone or Email)';

  @override
  String get recipientError =>
      'Enter a valid Egyptian phone (+20XXXXXXXXXX) or email';

  @override
  String get pointsLabel => 'Points Amount';

  @override
  String get pointsErrorMin => 'Minimum transfer is 100 points';

  @override
  String get pointsErrorMax => 'Insufficient balance';

  @override
  String get pointsErrorWhole => 'Points must be a whole number';

  @override
  String get noteLabel => 'Note (optional)';

  @override
  String get noteError => 'Note cannot exceed 150 characters';

  @override
  String get confirmTransfer => 'Confirm Transfer';

  @override
  String confirmMessage(int points, String recipient) {
    return 'You are about to transfer $points points to $recipient';
  }

  @override
  String get transferSuccess => 'Transfer Successful!';

  @override
  String newBalance(int balance) {
    return 'New Balance: $balance pts';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get done => 'Done';

  @override
  String get insufficientBalance => 'You don\'t have enough points';

  @override
  String get recipientNotFound => 'Recipient not found';

  @override
  String get points => 'pts';
}
