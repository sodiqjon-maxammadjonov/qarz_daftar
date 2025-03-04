part of 'debtor_bloc.dart';

@immutable
sealed class DebtorState extends Equatable {
  const DebtorState();

  @override
  List<Object> get props => [];
}

class DebtorInitial extends DebtorState {}

class DebtorsLoaded extends DebtorState {
  final List<Debtor> debtors;

  const DebtorsLoaded({required this.debtors});

  @override
  List<Object> get props => [debtors];
}

class DebtorLoading extends DebtorState {}

class DebtorSuccess extends DebtorState {}

class DebtorFailure extends DebtorState {
  final String errorMessage;

  const DebtorFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
