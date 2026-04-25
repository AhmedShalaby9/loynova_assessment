// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'محفظة شوب بلس';

  @override
  String get totalBalance => 'الرصيد الكلي';

  @override
  String get pendingPoints => 'معلق';

  @override
  String get expiringPoints => 'ينتهي قريباً';

  @override
  String get transferButton => 'تحويل نقاط';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterEarn => 'مكتسبة';

  @override
  String get filterRedeem => 'مستردة';

  @override
  String get filterTransfer => 'تحويلات';

  @override
  String get transactionEarn => 'مكتسب';

  @override
  String get transactionRedeem => 'مسترد';

  @override
  String get transactionTransferIn => 'مستلم';

  @override
  String get transactionTransferOut => 'محول';

  @override
  String get transactionPurchase => 'مشتريات';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusPending => 'معلق';

  @override
  String get statusFailed => 'فشل';

  @override
  String get retryButton => 'إعادة المحاولة';

  @override
  String get errorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get emptyTransactions => 'لا توجد معاملات';

  @override
  String get transferTitle => 'تحويل نقاط';

  @override
  String get recipientLabel => 'المستلم (هاتف أو بريد إلكتروني)';

  @override
  String get recipientError =>
      'أدخل رقم مصري صحيح (+20XXXXXXXXXX) أو بريد إلكتروني';

  @override
  String get pointsLabel => 'عدد النقاط';

  @override
  String get pointsErrorMin => 'الحد الأدنى للتحويل 100 نقطة';

  @override
  String get pointsErrorMax => 'الرصيد غير كافٍ';

  @override
  String get pointsErrorWhole => 'يجب أن تكون النقاط عدداً صحيحاً';

  @override
  String get noteLabel => 'ملاحظة (اختياري)';

  @override
  String get noteError => 'لا يمكن أن تتجاوز الملاحظة 150 حرفاً';

  @override
  String get confirmTransfer => 'تأكيد التحويل';

  @override
  String confirmMessage(int points, String recipient) {
    return 'أنت على وشك تحويل $points نقطة إلى $recipient';
  }

  @override
  String get transferSuccess => 'تم التحويل بنجاح!';

  @override
  String newBalance(int balance) {
    return 'الرصيد الجديد: $balance نقطة';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get done => 'تم';

  @override
  String get insufficientBalance => 'رصيدك غير كافٍ';

  @override
  String get recipientNotFound => 'المستلم غير موجود';

  @override
  String get points => 'نقطة';
}
