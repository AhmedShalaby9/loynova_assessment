import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n.dart';
import '../../../../main.dart' show appLocale;
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../widgets/balance_card.dart';
import '../widgets/filter_chips.dart';
import '../widgets/transaction_item.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const LoadWallet());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<WalletBloc>().add(const LoadMoreTransactions());
    }
  }

  Future<void> _refresh() async {
    context.read<WalletBloc>().add(const RefreshWallet());
  }

  void _toggleLocale() {
    appLocale.value = appLocale.value.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.appTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          ValueListenableBuilder<Locale>(
            valueListenable: appLocale,
            builder: (context, locale, _) {
              final showLabel = locale.languageCode == 'en' ? 'AR' : 'EN';
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: TextButton(
                  onPressed: _toggleLocale,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.08),
                    minimumSize: const Size(44, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  child: Text(showLabel),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: BlocBuilder<WalletBloc, WalletState>(
            builder: (context, state) {
              if (state is WalletInitial || state is WalletLoading) {
                return const _LoadingSkeleton();
              }
              if (state is WalletError) {
                return _ErrorView(
                  message: _localizedError(l10n, state.code, state.message),
                );
              }
              if (state is WalletLoaded) {
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _refresh,
                  child: _LoadedView(
                    state: state,
                    scrollController: _scrollController,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  String _localizedError(AppLocalizations l10n, String code, String fallback) {
    switch (code) {
      case 'INSUFFICIENT_BALANCE':
        return l10n.insufficientBalance;
      case 'RECIPIENT_NOT_FOUND':
        return l10n.recipientNotFound;
      default:
        return l10n.errorGeneric;
    }
  }
}

class _LoadedView extends StatelessWidget {
  final WalletLoaded state;
  final ScrollController scrollController;

  const _LoadedView({required this.state, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final count = state.filteredTransactions.length;
    final extraCount = (state.isLoadingMore || state.hasMore) ? 1 : 0;
    final totalItemCount = 2 + (count == 0 ? 1 : count) + extraCount;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: totalItemCount,
      itemBuilder: (context, index) {
        if (index == 0) return BalanceCard(balance: state.balance);
        if (index == 1) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(top: 24, bottom: 12),
            child: FilterChips(activeFilter: state.selectedFilter),
          );
        }
        if (count == 0 && index == 2) return const _EmptyState();

        final txIndex = index - 2;
        if (txIndex < count) {
          final tx = state.filteredTransactions[txIndex];
          return _TransactionContainer(
            first: txIndex == 0,
            last: txIndex == count - 1 && !state.hasMore && !state.isLoadingMore,
            child: TransactionItem(transaction: tx),
          );
        }

        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TransactionContainer extends StatelessWidget {
  final Widget child;
  final bool first;
  final bool last;
  const _TransactionContainer({
    required this.child,
    required this.first,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: first ? const Radius.circular(16) : Radius.zero,
          bottom: last ? const Radius.circular(16) : Radius.zero,
        ),
        border: Border(
          left: const BorderSide(color: AppColors.divider),
          right: const BorderSide(color: AppColors.divider),
          top: first
              ? const BorderSide(color: AppColors.divider)
              : BorderSide.none,
          bottom: last
              ? const BorderSide(color: AppColors.divider)
              : BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(
            5,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  context.read<WalletBloc>().add(const LoadWallet()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(l10n.retryButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.emptyTransactions,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
