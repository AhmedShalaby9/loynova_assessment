import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n.dart';
import '../../data/models/transaction.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({super.key, required this.transaction});

  bool get _isPositive =>
      transaction.type == TransactionType.EARN ||
      transaction.type == TransactionType.TRANSFER_IN ||
      transaction.type == TransactionType.PURCHASE;

  IconData get _typeIcon {
    switch (transaction.type) {
      case TransactionType.EARN:
        return Icons.star_rounded;
      case TransactionType.REDEEM:
        return Icons.redeem_rounded;
      case TransactionType.TRANSFER_IN:
        return Icons.call_received_rounded;
      case TransactionType.TRANSFER_OUT:
        return Icons.call_made_rounded;
      case TransactionType.PURCHASE:
        return Icons.shopping_bag_rounded;
    }
  }

  bool get _isDirectionalIcon =>
      transaction.type == TransactionType.TRANSFER_IN ||
      transaction.type == TransactionType.TRANSFER_OUT;

  String _statusLabel(AppLocalizations l10n) {
    switch (transaction.status) {
      case TransactionStatus.COMPLETED:
        return l10n.statusCompleted;
      case TransactionStatus.PENDING:
        return l10n.statusPending;
      case TransactionStatus.FAILED:
        return l10n.statusFailed;
    }
  }

  String _typeLabel(AppLocalizations l10n) {
    switch (transaction.type) {
      case TransactionType.EARN:
        return l10n.transactionEarn;
      case TransactionType.REDEEM:
        return l10n.transactionRedeem;
      case TransactionType.TRANSFER_IN:
        return l10n.transactionTransferIn;
      case TransactionType.TRANSFER_OUT:
        return l10n.transactionTransferOut;
      case TransactionType.PURCHASE:
        return l10n.transactionPurchase;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final pointsColor = _isPositive ? AppColors.success : AppColors.error;
    final sign = _isPositive ? '+' : '-';
    final fmt = NumberFormat('#,###', locale.toString());
    final dateFmt = DateFormat('MMM dd, yyyy', locale.toString());
    final isRtl = Directionality.of(context) == TextDirection.  rtl;

    final descriptionText = transaction.description.isEmpty
        ? _typeLabel(l10n)
        : transaction.description;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          _Logo(
            logoUrl: transaction.merchantLogo,
            icon: _typeIcon,
            flipIcon: _isDirectionalIcon && isRtl,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  descriptionText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateFmt.format(transaction.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${fmt.format(transaction.points)} ${l10n.points}',
                style: TextStyle(
                  color: pointsColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              _StatusBadge(
                status: transaction.status,
                label: _statusLabel(l10n),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final String? logoUrl;
  final IconData icon;
  final bool flipIcon;

  const _Logo({
    required this.logoUrl,
    required this.icon,
    this.flipIcon = false,
  });

  Widget _iconWidget() {
    final iconWidget = Icon(icon, color: AppColors.primary, size: 22);
    return flipIcon
        ? Transform.flip(flipX: true, child: iconWidget)
        : iconWidget;
  }

  @override
  Widget build(BuildContext context) {
    if (logoUrl == null || logoUrl!.isEmpty) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: _iconWidget(),
      );
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: logoUrl!,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: 44,
          height: 44,
          color: AppColors.divider,
        ),
        errorWidget: (_, __, ___) => Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: _iconWidget(),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TransactionStatus status;
  final String label;
  const _StatusBadge({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    switch (status) {
      case TransactionStatus.COMPLETED:
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        break;
      case TransactionStatus.PENDING:
        bg = const Color(0xFFF59E0B).withValues(alpha: 0.15);
        fg = const Color(0xFFB45309);
        break;
      case TransactionStatus.FAILED:
        bg = AppColors.error.withValues(alpha: 0.12);
        fg = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
