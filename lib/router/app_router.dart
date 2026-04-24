import 'package:go_router/go_router.dart';
import '../features/wallet/presentation/screens/transfer_screen.dart';
import '../features/wallet/presentation/screens/wallet_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String wallet = '/wallet';
  static const String transfer = '/wallet/transfer';

  static const String walletName = 'wallet';
  static const String transferName = 'transfer';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.wallet,
  errorBuilder: (context, state) => const WalletScreen(),
  redirect: (context, state) {
    final matched = state.matchedLocation;
    if (matched != AppRoutes.wallet && matched != AppRoutes.transfer) {
      return AppRoutes.wallet;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.wallet,
      name: AppRoutes.walletName,
      builder: (context, state) => const WalletScreen(),
    ),
    GoRoute(
      path: AppRoutes.transfer,
      name: AppRoutes.transferName,
      builder: (context, state) {
        final balance = (state.extra as int?) ?? 0;
        return TransferScreen(currentBalance: balance);
      },
    ),
  ],
);
