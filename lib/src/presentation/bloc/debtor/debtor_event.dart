part of 'debtor_bloc.dart';

@immutable
sealed class DebtorEvent extends Equatable {
  const DebtorEvent();

  @override
  List<Object?> get props => [];
}

class LoadDebtorsEvent extends DebtorEvent {
  final String? name;
  const LoadDebtorsEvent({this.name});

  @override
  List<Object?> get props => [name];
}

class LoadSelectedDebtors extends DebtorEvent {}

class AddDebtorEvent extends DebtorEvent {
  final String name;
  const AddDebtorEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdateDebtorEvent extends DebtorEvent {
  final String id;
  final String? name;
  final int? balance;
  final bool? isSelected;
  const UpdateDebtorEvent({this.name, this.balance, this.isSelected, required this.id});

  @override
  List<Object?> get props => [id, name, balance, isSelected];
}

class DeleteDebtorEvent extends DebtorEvent {
  final String id;
  const DeleteDebtorEvent(this.id);

  @override
  List<Object?> get props => [id];
}
