import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n.dart';
import '../../data/models/transaction.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';

enum _FilterOption { all, earn, redeem, transfer }

extension on _FilterOption {
  TransactionType? get type {
    switch (this) {
      case _FilterOption.all:
        return null;
      case _FilterOption.earn:
        return TransactionType.EARN;
      case _FilterOption.redeem:
        return TransactionType.REDEEM;
      case _FilterOption.transfer:
        return TransactionType.TRANSFER_OUT;
    }
  }

  String label(AppLocalizations l10n) {
    switch (this) {
      case _FilterOption.all:
        return l10n.filterAll;
      case _FilterOption.earn:
        return l10n.filterEarn;
      case _FilterOption.redeem:
        return l10n.filterRedeem;
      case _FilterOption.transfer:
        return l10n.filterTransfer;
    }
  }
}

class FilterChips extends StatelessWidget {
  final TransactionType? activeFilter;

  const FilterChips({super.key, required this.activeFilter});

  _FilterOption _activeOption() {
    if (activeFilter == TransactionType.EARN) return _FilterOption.earn;
    if (activeFilter == TransactionType.REDEEM) return _FilterOption.redeem;
    if (activeFilter == TransactionType.TRANSFER_OUT ||
        activeFilter == TransactionType.TRANSFER_IN) {
      return _FilterOption.transfer;
    }
    return _FilterOption.all;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = _activeOption();
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: _FilterOption.values.map((option) {
          final selected = option == active;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(
              label: Text(option.label(l10n)),
              selected: selected,
              onSelected: (_) => context
                  .read<WalletBloc>()
                  .add(FilterTransactions(option.type)),
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.divider,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}
