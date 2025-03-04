part of 'debtor_bloc.dart';

@immutable
sealed class DebtorEvent extends Equatable {
  const DebtorEvent();

  @override
  List<Object> get props => [];
}

class GetDebtorsEvent extends DebtorEvent {

}

class AddTransaction extends DebtorEvent {

}

class AddDebtorEvent extends DebtorEvent {
  final String name;
  final double amount;
  final bool isDebt;

  const AddDebtorEvent(this.name, this.amount, this.isDebt);

  @override
  List<Object> get props => [name, amount, isDebt];
}
