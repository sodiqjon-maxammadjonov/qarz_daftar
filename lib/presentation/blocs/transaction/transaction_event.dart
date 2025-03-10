part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class LoadTransactions extends TransactionEvent {
  final String debtorId;

  const LoadTransactions({required this.debtorId});

  @override
  List<Object> get props => [debtorId];
}

class AddTransaction extends TransactionEvent {
  final String debtorId;
  final double amount;
  final bool isDebt;
  final String description;

  const AddTransaction({
    required this.debtorId,
    required this.amount,
    required this.isDebt,
    required this.description,
  });

  @override
  List<Object> get props => [debtorId, amount, isDebt, description];
}

class UpdateTransaction extends TransactionEvent {
  final Transactions transaction;

  const UpdateTransaction({required this.transaction});

  @override
  List<Object> get props => [transaction];
}

class DeleteTransaction extends TransactionEvent {
  final String transactionId;
  final String debtorId;

  const DeleteTransaction({
    required this.transactionId,
    required this.debtorId,
  });

  @override
  List<Object> get props => [transactionId, debtorId];
}
