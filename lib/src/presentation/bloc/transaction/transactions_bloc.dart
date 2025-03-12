import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:qarz_daftar/src/data/models/transacrions.dart';
import 'package:qarz_daftar/src/data/service/transaction_service.dart';
import '../../../data/models/currency_and_type.dart';

part 'transactions_event.dart';

part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc() : super(TransactionsInitial()) {
    on<LoadTransactions>(loadTransactions);
    on<AddTransactions>(addTransactions);
    on<DeleteTransactions>(deleteTransactions);
    on<UpdateTransactions>(updateTransactions);
  }

  FutureOr<void> loadTransactions(
      LoadTransactions event, Emitter<TransactionsState> emit) async {
    await TransactionService(emit: emit)
        .getTransactionsByDebtor(event.debtorId);
  }

  FutureOr<void> addTransactions(
      AddTransactions event, Emitter<TransactionsState> emit) async {
    await TransactionService(emit: emit).createTransaction(
        debtorId: event.debtorId,
        amount: event.amount,
        currency: event.currency,
        description: event.description,
        date: event.date,
        type: event.type);
    add(LoadTransactions(event.debtorId));
  }

  FutureOr<void> deleteTransactions(
      DeleteTransactions event, Emitter<TransactionsState> emit) async {
    await TransactionService(emit: emit).deleteTransaction(transactionId: event.transactionId, debtorId: event.debtorId, );
  }

  FutureOr<void> updateTransactions(
      UpdateTransactions event, Emitter<TransactionsState> emit) async {
    await TransactionService(emit: emit).updateTransaction(
      debtorId: event.debtorId,
      transactionId: event.transactionId,
      amount: event.amount,
      description: event.description,
      currency: event.currency,
      type: event.type
    );
  }
}
