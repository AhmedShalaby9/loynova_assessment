import 'package:equatable/equatable.dart';

class TransferRequest extends Equatable {
  final String recipient;
  final int points;
  final String? note;

  const TransferRequest({
    required this.recipient,
    required this.points,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'recipient': recipient,
        'points': points,
        'note': note,
      };

  @override
  List<Object?> get props => [recipient, points, note];
}
