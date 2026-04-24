import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
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

  String? _recipientError;
  String? _pointsError;
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
    if (value.isEmpty) return 'Recipient is required';
    if (_phoneRegex.hasMatch(value)) return null;
    if (_emailRegex.hasMatch(value)) return null;
    return 'Enter a valid Egyptian phone (+20XXXXXXXXXX) or email';
  }

  String? _validatePoints(String value) {
    if (value.isEmpty) return 'Points amount is required';
    final n = int.tryParse(value);
    if (n == null) return 'Enter a whole number';
    if (n < 100) return 'Minimum transfer is 100 points';
    if (n > widget.currentBalance) return 'Exceeds available balance';
    return null;
  }

  void _validateAll() {
    final rErr = _validateRecipient(_recipientController.text);
    final pErr = _validatePoints(_pointsController.text);
    setState(() {
      _recipientError = rErr;
      _pointsError = pErr;
      _isFormValid = rErr == null && pErr == null;
    });
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
    final fmt = NumberFormat('#,###');
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
            const Text(
              'Confirm Transfer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Please review the details before proceeding.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            _ConfirmRow(label: 'Recipient', value: request.recipient),
            const SizedBox(height: 12),
            _ConfirmRow(
              label: 'Amount',
              value: '${fmt.format(request.points)} pts',
              highlight: true,
            ),
            if (request.note != null) ...[
              const SizedBox(height: 12),
              _ConfirmRow(label: 'Note', value: request.note!),
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
                    child: const Text('Cancel'),
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
                    child: const Text('Confirm'),
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
    final fmt = NumberFormat('#,###');
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 10),
            Text('Transfer Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _ConfirmRow(label: 'Transaction ID', value: transactionId),
            const SizedBox(height: 10),
            _ConfirmRow(
              label: 'New Balance',
              value: '${fmt.format(newBalance)} pts',
              highlight: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balanceFmt = NumberFormat('#,###').format(widget.currentBalance);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Transfer Points',
          style: TextStyle(
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
              setState(() => _pointsError = state.message);
            } else if (state.code == 'RECIPIENT_NOT_FOUND') {
              setState(() => _recipientError = state.message);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
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
                    _BalanceBanner(balance: balanceFmt),
                    const SizedBox(height: 24),
                    _FieldLabel('Recipient (Phone or Email)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _recipientController,
                      keyboardType: TextInputType.emailAddress,
                      enableSuggestions: false,
                      autocorrect: false,
                      autofillHints: null,
                      decoration: _decoration(
                        hint: '+20XXXXXXXXXX or email@example.com',
                        error: _recipientError,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FieldLabel('Points Amount'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pointsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _decoration(
                        hint: 'Enter amount (min 100)',
                        error: _pointsError,
                        suffix: 'pts',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Available: $balanceFmt pts',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FieldLabel('Note (optional)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noteController,
                      maxLength: 150,
                      maxLines: 3,
                      decoration: _decoration(
                        hint: 'Add a note for the recipient',
                      ).copyWith(
                        counterText:
                            '${_noteController.text.length}/150',
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
                            : const Text('Transfer Points'),
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
  const _BalanceBanner({required this.balance});

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'Available Balance',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$balance pts',
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
