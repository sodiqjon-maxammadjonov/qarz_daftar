import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:qarz_daftar/core/models/transaction.dart';
import 'package:qarz_daftar/data/services/transaction_service.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionService _transactionService = TransactionService();

  TransactionBloc() : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  FutureOr<void> _onLoadTransactions(LoadTransactions event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final monthlyTransactions = await _transactionService.getMonthlyTransactionsForDebtor(event.debtorId);
      emit(TransactionsLoaded(monthlyTransactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  FutureOr<void> _onAddTransaction(AddTransaction event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      await _transactionService.addTransaction(event.debtorId, event.amount, event.isDebt, event.description);
      emit(TransactionAdded());
      add(LoadTransactions(debtorId: event.debtorId)); // reload transactions
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  FutureOr<void> _onUpdateTransaction(UpdateTransaction event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      await _transactionService.updateTransaction(event.transaction);
      emit(TransactionUpdated());
      add(LoadTransactions(debtorId: event.transaction.debtorId)); // reload transactions
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  FutureOr<void> _onDeleteTransaction(DeleteTransaction event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      await _transactionService.deleteTransaction(event.transactionId, event.debtorId);
      emit(TransactionDeleted());
      add(LoadTransactions(debtorId: event.debtorId)); // reload transactions
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}