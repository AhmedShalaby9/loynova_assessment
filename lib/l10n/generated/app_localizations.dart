import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ShopPlus Wallet'**
  String get appTitle;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @pendingPoints.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingPoints;

  /// No description provided for @expiringPoints.
  ///
  /// In en, this message translates to:
  /// **'Expiring'**
  String get expiringPoints;

  /// No description provided for @transferButton.
  ///
  /// In en, this message translates to:
  /// **'Transfer Points'**
  String get transferButton;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterEarn.
  ///
  /// In en, this message translates to:
  /// **'Earn'**
  String get filterEarn;

  /// No description provided for @filterRedeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get filterRedeem;

  /// No description provided for @filterTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get filterTransfer;

  /// No description provided for @transactionEarn.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get transactionEarn;

  /// No description provided for @transactionRedeem.
  ///
  /// In en, this message translates to:
  /// **'Redeemed'**
  String get transactionRedeem;

  /// No description provided for @transactionTransferIn.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get transactionTransferIn;

  /// No description provided for @transactionTransferOut.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get transactionTransferOut;

  /// No description provided for @transactionPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get transactionPurchase;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @emptyTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get emptyTransactions;

  /// No description provided for @transferTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer Points'**
  String get transferTitle;

  /// No description provided for @recipientLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient (Phone or Email)'**
  String get recipientLabel;

  /// No description provided for @recipientError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Egyptian phone (+20XXXXXXXXXX) or email'**
  String get recipientError;

  /// No description provided for @pointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Points Amount'**
  String get pointsLabel;

  /// No description provided for @pointsErrorMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum transfer is 100 points'**
  String get pointsErrorMin;

  /// No description provided for @pointsErrorMax.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get pointsErrorMax;

  /// No description provided for @pointsErrorWhole.
  ///
  /// In en, this message translates to:
  /// **'Points must be a whole number'**
  String get pointsErrorWhole;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteLabel;

  /// No description provided for @noteError.
  ///
  /// In en, this message translates to:
  /// **'Note cannot exceed 150 characters'**
  String get noteError;

  /// No description provided for @confirmTransfer.
  ///
  /// In en, this message translates to:
  /// **'Confirm Transfer'**
  String get confirmTransfer;

  /// No description provided for @confirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You are about to transfer {points} points to {recipient}'**
  String confirmMessage(int points, String recipient);

  /// No description provided for @transferSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transfer Successful!'**
  String get transferSuccess;

  /// No description provided for @newBalance.
  ///
  /// In en, this message translates to:
  /// **'New Balance: {balance} pts'**
  String newBalance(int balance);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @insufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have enough points'**
  String get insufficientBalance;

  /// No description provided for @recipientNotFound.
  ///
  /// In en, this message translates to:
  /// **'Recipient not found'**
  String get recipientNotFound;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get points;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
