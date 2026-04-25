import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n.dart';
import '../../data/models/transfer_request.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class TransferScreen extends StatefulWidget {
  final int currentBalance;

  const TransferScreen({super.key, required this.currentBalance});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _pointsController = TextEditingController();
  final _noteController = TextEditingController();

  String? _recipientErrorKey;
  String? _pointsErrorKey;
  bool _isFormValid = false;
  bool _submitting = false;

  static final _phoneRegex = RegExp(r'^\+20\d{10}$');
  static final _emailRegex =
      RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

  @override
  void initState() {
    super.initState();
    _recipientController.addListener(_validateAll);
    _pointsController.addListener(_validateAll);
    _noteController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _pointsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String? _validateRecipient(String value) {
    if (value.isEmpty) return 'recipient_required';
    if (_phoneRegex.hasMatch(value)) return null;
    if (_emailRegex.hasMatch(value)) return null;
    return 'recipient_invalid';
  }

  String? _validatePoints(String value) {
    if (value.isEmpty) return 'points_required';
    final n = int.tryParse(value);
    if (n == null) return 'points_whole';
    if (n < 100) return 'points_min';
    if (n > widget.currentBalance) return 'points_max';
    return null;
  }

  void _validateAll() {
    final rErr = _validateRecipient(_recipientController.text);
    final pErr = _validatePoints(_pointsController.text);
    setState(() {
      _recipientErrorKey = rErr;
      _pointsErrorKey = pErr;
      _isFormValid = rErr == null && pErr == null;
    });
  }

  String? _resolveRecipientError(AppLocalizations l10n) {
    switch (_recipientErrorKey) {
      case 'recipient_required':
      case 'recipient_invalid':
        return l10n.recipientError;
      case 'recipient_not_found':
        return l10n.recipientNotFound;
      default:
        return null;
    }
  }

  String? _resolvePointsError(AppLocalizations l10n) {
    switch (_pointsErrorKey) {
      case 'points_required':
      case 'points_whole':
        return l10n.pointsErrorWhole;
      case 'points_min':
        return l10n.pointsErrorMin;
      case 'points_max':
      case 'insufficient_balance':
        return l10n.pointsErrorMax;
      default:
        return null;
    }
  }

  Future<void> _submit() async {
    if (!_isFormValid) return;
    final request = TransferRequest(
      recipient: _recipientController.text,
      points: int.parse(_pointsController.text),
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );
    final confirmed = await _showConfirmationSheet(request);
    if (confirmed == true && mounted) {
      context.read<WalletBloc>().add(TransferPoints(request));
    }
  }

  Future<bool?> _showConfirmationSheet(TransferRequest request) {
    final l10n = AppLocalizations.of(context);
    final fmt = NumberFormat('#,###', Localizations.localeOf(context).toString());
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.confirmTransfer,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.confirmMessage(request.points, request.recipient),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            _ConfirmRow(label: l10n.recipientLabel, value: request.recipient),
            const SizedBox(height: 12),
            _ConfirmRow(
              label: l10n.pointsLabel,
              value: '${fmt.format(request.points)} ${l10n.points}',
              highlight: true,
            ),
            if (request.note != null) ...[
              const SizedBox(height: 12),
              _ConfirmRow(label: l10n.noteLabel, value: request.note!),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    child: Text(l10n.confirm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSuccessDialog(String transactionId, int newBalance) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.transferSuccess)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _ConfirmRow(label: 'ID', value: transactionId),
            const SizedBox(height: 10),
            Text(
              l10n.newBalance(newBalance),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final balanceFmt =
        NumberFormat('#,###', locale.toString()).format(widget.currentBalance);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Transform.flip(
            flipX: isRtl,
            child: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.transferTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocListener<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is TransferLoading) {
            setState(() => _submitting = true);
          } else {
            setState(() => _submitting = false);
          }
          if (state is TransferError) {
            if (state.code == 'INSUFFICIENT_BALANCE') {
              setState(() => _pointsErrorKey = 'insufficient_balance');
            } else if (state.code == 'RECIPIENT_NOT_FOUND') {
              setState(() => _recipientErrorKey = 'recipient_not_found');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.errorGeneric),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
          if (state is TransferSuccess) {
            _showSuccessDialog(
              state.result.transactionId,
              state.result.newBalance,
            ).then((_) {
              if (mounted) context.go('/wallet');
            });
          }
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BalanceBanner(balance: balanceFmt, unit: l10n.points),
                    const SizedBox(height: 24),
                    _FieldLabel(l10n.recipientLabel),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _recipientController,
                      keyboardType: TextInputType.emailAddress,
                      enableSuggestions: false,
                      autocorrect: false,
                      autofillHints: null,
                      decoration: _decoration(
                        hint: '+20XXXXXXXXXX',
                        error: _resolveRecipientError(l10n),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FieldLabel(l10n.pointsLabel),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pointsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _decoration(
                        hint: '100+',
                        error: _resolvePointsError(l10n),
                        suffix: l10n.points,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$balanceFmt ${l10n.points}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FieldLabel(l10n.noteLabel),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noteController,
                      maxLength: 150,
                      maxLines: 3,
                      decoration: _decoration(hint: '').copyWith(
                        counterText: '${_noteController.text.length}/150',
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            (_isFormValid && !_submitting) ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.4),
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(l10n.transferButton),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration({
    required String hint,
    String? error,
    String? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      errorText: error,
      suffixText: suffix,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ConfirmRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 16 : 14,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _BalanceBanner extends StatelessWidget {
  final String balance;
  final String unit;
  const _BalanceBanner({required this.balance, required this.unit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.totalBalance,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$balance $unit',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
