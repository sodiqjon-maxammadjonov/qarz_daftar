part of 'debtor_bloc.dart';

@immutable
abstract class DebtorEvent extends Equatable {
  const DebtorEvent();

  @override
  List<Object> get props => [];
}

class LoadDebtorsEvent extends DebtorEvent {}

class LoadDebtorByIdEvent extends DebtorEvent {
  final String id;

  const LoadDebtorByIdEvent(this.id);

  @override
  List<Object> get props => [id];
}

class AddDebtorEvent extends DebtorEvent {
  final String name;
  final double amount;
  final bool isDebt;

  const AddDebtorEvent({
    required this.name,
    required this.amount,
    required this.isDebt,
  });

  @override
  List<Object> get props => [name, amount, isDebt];
}

class UpdateDebtorEvent extends DebtorEvent {
  final Debtor debtor;

  const UpdateDebtorEvent(this.debtor);

  @override
  List<Object> get props => [debtor];
}

class DeleteDebtorEvent extends DebtorEvent {
  final String id;

  const DeleteDebtorEvent(this.id);

  @override
  List<Object> get props => [id];
}
