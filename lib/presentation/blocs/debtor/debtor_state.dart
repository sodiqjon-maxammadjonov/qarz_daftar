part of 'debtor_bloc.dart';

@immutable
abstract class DebtorState extends Equatable {
  const DebtorState();

  @override
  List<Object> get props => [];
}

class DebtorInitial extends DebtorState {}

class DebtorLoading extends DebtorState {}

class DebtorsLoaded extends DebtorState {
  final List<Debtor> debtors;

  const DebtorsLoaded(this.debtors);

  @override
  List<Object> get props => [debtors];
}

class DebtorLoaded extends DebtorState {
  final Debtor debtor;

  const DebtorLoaded(this.debtor);

  @override
  List<Object> get props => [debtor];
}

class DebtorCreated extends DebtorState {
  final String id;

  const DebtorCreated(this.id);

  @override
  List<Object> get props => [id];
}

class DebtorUpdated extends DebtorState {}

class DebtorDeleted extends DebtorState {}

class DebtorError extends DebtorState {
  final String message;

  const DebtorError(this.message);

  @override
  List<Object> get props => [message];
}
