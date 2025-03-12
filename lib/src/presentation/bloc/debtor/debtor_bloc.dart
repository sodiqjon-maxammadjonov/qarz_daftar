import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:qarz_daftar/src/data/service/debtor_service.dart';

import '../../../data/models/debtor.dart';

part 'debtor_event.dart';

part 'debtor_state.dart';

class DebtorBloc extends Bloc<DebtorEvent, DebtorState> {
  DebtorBloc() : super(DebtorInitial()) {
    on<LoadDebtorsEvent>(_loadDebtors);
    on<LoadSelectedDebtors>(_selectedDebtor);
    on<AddDebtorEvent>(_addDebtor);
    on<DeleteDebtorEvent>(_deleteDebtor);
    on<UpdateDebtorEvent>(_updateDebtor);
  }

  Future<void> _loadDebtors(
    LoadDebtorsEvent event,
    Emitter<DebtorState> emit,
  ) async {
    await DebtorService(emit: emit).getDebtors(name: event.name);
  }

  FutureOr<void> _addDebtor(
      AddDebtorEvent event, Emitter<DebtorState> emit) async {
    await DebtorService(emit: emit).createDebtor(event.name);
    add(LoadDebtorsEvent());
  }

  FutureOr<void> _deleteDebtor(
      DeleteDebtorEvent event, Emitter<DebtorState> emit) async {
    await DebtorService(emit: emit).deleteDebtor(event.id);
    add(LoadDebtorsEvent());
  }

  FutureOr<void> _updateDebtor(
      UpdateDebtorEvent event, Emitter<DebtorState> emit) async {
    await DebtorService(emit: emit).updateDebtor(event.id,
        name: event.name, balance: event.balance, isSelected: event.isSelected);
    add(LoadDebtorsEvent());
  }
  FutureOr<void> _selectedDebtor(
      LoadSelectedDebtors event, Emitter<DebtorState> emit) async {
    await DebtorService(emit: emit).getSelectedDebtors();
  }
}
