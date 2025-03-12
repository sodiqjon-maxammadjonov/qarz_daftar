part of 'debtor_bloc.dart';

@immutable
sealed class DebtorState extends Equatable {
  const DebtorState();

  @override
  List<Object?> get props => [];
}

class DebtorInitial extends DebtorState {}

class DebtorLoading extends DebtorState {}

class DebtorLoaded extends DebtorState {
  final List<Debtor> debtors;
  const DebtorLoaded(this.debtors);

  @override
  List<Object?> get props => [debtors];
}

class DebtorSuccess extends DebtorState {
  final String message;
  const DebtorSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DebtorError extends DebtorState {
  final String message;
  const DebtorError(this.message);

  @override
  List<Object?> get props => [message];
}