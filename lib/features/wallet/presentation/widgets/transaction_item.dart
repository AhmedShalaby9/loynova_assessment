import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    final pointsColor = _isPositive ? AppColors.success : AppColors.error;
    final sign = _isPositive ? '+' : '-';
    final fmt = NumberFormat('#,###');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          _Logo(logoUrl: transaction.merchantLogo, icon: _typeIcon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
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
                  DateFormat('MMM dd, yyyy').format(transaction.createdAt),
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
                '$sign${fmt.format(transaction.points)} pts',
                style: TextStyle(
                  color: pointsColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              _StatusBadge(status: transaction.status),
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
  const _Logo({required this.logoUrl, required this.icon});

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
        child: Icon(icon, color: AppColors.primary, size: 22),
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
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TransactionStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final String label;
    switch (status) {
      case TransactionStatus.COMPLETED:
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        label = 'Completed';
        break;
      case TransactionStatus.PENDING:
        bg = const Color(0xFFF59E0B).withValues(alpha: 0.15);
        fg = const Color(0xFFB45309);
        label = 'Pending';
        break;
      case TransactionStatus.FAILED:
        bg = AppColors.error.withValues(alpha: 0.12);
        fg = AppColors.error;
        label = 'Failed';
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
