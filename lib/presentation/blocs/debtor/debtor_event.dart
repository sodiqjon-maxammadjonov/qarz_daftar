part of 'debtor_bloc.dart';

@immutable
sealed class DebtorEvent extends Equatable {
  const DebtorEvent();

  @override
  List<Object> get props => [];
}

class GetDebtorsEvent extends DebtorEvent {}

class AddTransactionToDebtorEvent extends DebtorEvent {
  final String debtorId;
  final double amount;
  final bool isDebt;
  final String? description;

  const AddTransactionToDebtorEvent({
    required this.debtorId,
    required this.amount,
    required this.isDebt,
    this.description
  });

  @override
  List<Object> get props => [debtorId, amount, isDebt];
}

class GetTransactionsForDebtorEvent extends DebtorEvent {
  final String debtorId;

  const GetTransactionsForDebtorEvent({required this.debtorId});

  @override
  List<Object> get props => [debtorId];
}

class AddDebtorEvent extends DebtorEvent {
  final String name;
  final double amount;
  final bool isDebt;

  const AddDebtorEvent(this.name, this.amount, this.isDebt);

  @override
  List<Object> get props => [name, amount, isDebt];
}