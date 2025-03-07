import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:qarz_daftar/core/models/debtor.dart';
import 'package:qarz_daftar/data/services/debtor_service.dart';

part 'debtor_event.dart';
part 'debtor_state.dart';

class DebtorBloc extends Bloc<DebtorEvent, DebtorState> {
  final DebtorService _debtorService = DebtorService();

  DebtorBloc() : super(DebtorInitial()) {
    on<LoadDebtorsEvent>(_onLoadDebtors);
    on<LoadDebtorByIdEvent>(_onLoadDebtorById);
    on<AddDebtorEvent>(_onAddDebtor);
    on<UpdateDebtorEvent>(_onUpdateDebtor);
    on<DeleteDebtorEvent>(_onDeleteDebtor);
  }

  FutureOr<void> _onLoadDebtors(
      LoadDebtorsEvent event,
      Emitter<DebtorState> emit
      ) async {
    emit(DebtorLoading());

    try {
      final debtors = await _debtorService.getAllDebtors();
      emit(DebtorsLoaded(debtors));
    } catch (e) {
      emit(DebtorError(e.toString()));
    }
  }

  FutureOr<void> _onLoadDebtorById(
      LoadDebtorByIdEvent event,
      Emitter<DebtorState> emit
      ) async {
    emit(DebtorLoading());

    try {
      final debtor = await _debtorService.getDebtorById(event.id);
      emit(DebtorLoaded(debtor));
    } catch (e) {
      emit(DebtorError(e.toString()));
    }
  }

  FutureOr<void> _onAddDebtor(
      AddDebtorEvent event,
      Emitter<DebtorState> emit
      ) async {
    emit(DebtorLoading());

    try {
      final debtorId = await _debtorService.addDebtor(
        event.name,
        event.amount,
        event.isDebt,
      );
      emit(DebtorCreated(debtorId));

      add(LoadDebtorsEvent());
    } catch (e) {
      emit(DebtorError(e.toString()));
    }
  }

  FutureOr<void> _onUpdateDebtor(
      UpdateDebtorEvent event,
      Emitter<DebtorState> emit
      ) async {
    emit(DebtorLoading());

    try {
      await _debtorService.updateDebtor(event.debtor);
      emit(DebtorUpdated());
      add(LoadDebtorsEvent());
    } catch (e) {
      emit(DebtorError(e.toString()));
    }
  }

  FutureOr<void> _onDeleteDebtor(
      DeleteDebtorEvent event,
      Emitter<DebtorState> emit
      ) async {
    emit(DebtorLoading());

    try {
      await _debtorService.deleteDebtor(event.id);
      emit(DebtorDeleted());
    } catch (e) {
      emit(DebtorError(e.toString()));
    }
  }
}
