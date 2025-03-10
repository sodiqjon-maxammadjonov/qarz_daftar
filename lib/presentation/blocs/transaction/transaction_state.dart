part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionsLoaded extends TransactionState {
  final Map<String, List<Transactions>> monthlyTransactions;

  const TransactionsLoaded(this.monthlyTransactions);

  @override
  List<Object> get props => [monthlyTransactions];
}

class TransactionAdded extends TransactionState {}

class TransactionUpdated extends TransactionState {}

class TransactionDeleted extends TransactionState {}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object> get props => [message];
}