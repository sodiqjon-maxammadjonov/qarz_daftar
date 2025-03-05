import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:qarz_daftar/core/models/debtor.dart';
import 'package:qarz_daftar/data/services/debtor_func.dart';
import 'package:qarz_daftar/data/services/transaction_func.dart';

import '../../../core/models/transaction.dart';

part 'debtor_event.dart';
part 'debtor_state.dart';

class DebtorBloc extends Bloc<DebtorEvent, DebtorState> {
  DebtorBloc() : super(DebtorInitial()) {
    on<AddDebtorEvent>(addDebtor);
    on<GetDebtorsEvent>(getDebtor);
    on<GetTransactionsForDebtorEvent>(getTransactionsForDebtor);
  }

  Future<void> addDebtor(
      AddDebtorEvent event,
      Emitter<DebtorState> emit,
      ) async {
    try {
      await DebtorFunc(emit: emit).addDebtor(event.name, event.amount, event.isDebt);
    } catch (e) {
      emit(DebtorFailure("Debtor qo'shishda xatolik: $e"));
    }
  }

  Future<void> getDebtor(
      GetDebtorsEvent event,
      Emitter<DebtorState> emit,
      ) async {
    try {
      await DebtorFunc(emit: emit).getDebtors();
    } catch (e) {
      emit(DebtorFailure("Debtorlarni olishda xatolik: $e"));
    }
  }

  FutureOr<void> getTransactionsForDebtor(
      GetTransactionsForDebtorEvent event,
      Emitter<DebtorState> emit,
      ) async {
    try {
      await TransactionFunc(emit: emit).getTransactionsForDebtor(event.debtorId);
    } catch (e) {
      emit(DebtorFailure("Tranzaksiyalarni olishda hatolik: $e"));
    }
  }
}