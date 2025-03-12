part of 'transactions_bloc.dart';

@immutable
sealed class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<Transactions> transactions;
  const TransactionsLoaded({required this.transactions});

  @override
  List<Object?> get props => [transactions];
}

class TransactionsSuccess extends TransactionsState {
  final String message;
  const TransactionsSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class TransactionsError extends TransactionsState {
  final String message;
  const TransactionsError({required this.message});

  @override
  List<Object?> get props => [message];
}
