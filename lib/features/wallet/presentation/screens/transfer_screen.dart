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

  void _submit() {
    if (!_isFormValid) return;
    final request = TransferRequest(
      recipient: _recipientController.text,
      points: int.parse(_pointsController.text),
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );
    context.read<WalletBloc>().add(TransferPoints(request));
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transfer completed successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            context.go('/wallet');
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
