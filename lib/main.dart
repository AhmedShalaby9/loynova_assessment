import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/wallet/data/repository/mock_wallet_repository.dart';
import 'features/wallet/data/repository/wallet_repository.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';
import 'router/app_router.dart';

void main() {
  runApp(const ShopPlusWalletApp());
}

class ShopPlusWalletApp extends StatelessWidget {
  const ShopPlusWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<WalletRepository>(
      create: (_) => MockWalletRepository(),
      child: BlocProvider<WalletBloc>(
        create: (ctx) =>
            WalletBloc(repository: ctx.read<WalletRepository>()),
        child: MaterialApp.router(
          title: 'ShopPlus Wallet',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
