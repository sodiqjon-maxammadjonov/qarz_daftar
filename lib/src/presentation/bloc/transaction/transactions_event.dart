part of 'transactions_bloc.dart';

@immutable
sealed class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionsEvent {
  final String debtorId;
  const LoadTransactions(this.debtorId);

  @override
  List<Object?> get props => [debtorId];
}

class AddTransactions extends TransactionsEvent {
  final String debtorId;
  final double amount;
  final Currency currency;
  final String description;
  final DateTime date;
  final TransactionType type;

  const AddTransactions({
    required this.debtorId,
    required this.amount,
    required this.currency,
    required this.description,
    required this.date,
    required this.type,
  });

  @override
  List<Object?> get props => [debtorId, amount, currency, description, date, type];
}

class UpdateTransactions extends TransactionsEvent {
  final String debtorId;
  final String transactionId;
  final double? amount;
  final Currency? currency;
  final String? description;
  final TransactionType? type;

  const UpdateTransactions({
    required this.transactionId,
    required this.debtorId,
    this.amount,
    this.currency,
    this.description,
    this.type,
  });

  @override
  List<Object?> get props => [transactionId, debtorId, amount, currency, description, type];
}

class DeleteTransactions extends TransactionsEvent {
  final String debtorId;
  final String transactionId;

  const DeleteTransactions(this.transactionId, this.debtorId);

  @override
  List<Object?> get props => [transactionId, debtorId];
}
