import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qarz_daftar/src/data/models/currency_and_type.dart';
import 'package:qarz_daftar/src/data/models/transacrions.dart';
import 'package:qarz_daftar/src/presentation/bloc/transaction/transactions_bloc.dart';

class TransactionService {
  final Emitter<TransactionsState> emit;
  TransactionService({required this.emit});
  final CollectionReference _transactionCollection =
  FirebaseFirestore.instance.collection('transactions');
  final CollectionReference _debtorCollection =
  FirebaseFirestore.instance.collection('debtors');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> createTransaction({
    required String debtorId,
    required double amount,
    required Currency currency,
    required String description,
    required DateTime date,
    required TransactionType type,
  }) async {
    try {
      final transactionRef = await _transactionCollection.add({
        'debtor_id': debtorId,
        'amount': amount,
        'currency': currency.name,
        'description': description,
        'date': Timestamp.fromDate(date),
        'type': type.name,
      });
      emit(TransactionsSuccess(message: 'Muvafaqiyatli qo\'shildi',));

      await _calculateBalance(debtorId);
      await _calculateUSDBalance(debtorId);
      await _updateDebtorBalance(debtorId);
      return transactionRef.id;
    } catch (e) {
      print('Tranzaksiyani yaratishda xatolik: $e');
      return null;
    }
  }

  Future<void> getTransactionsByDebtor(String debtorId) async {
    try {
      emit(TransactionsLoading());

      final querySnapshot = await _transactionCollection
          .where('debtor_id', isEqualTo: debtorId)
          .orderBy('date', descending: true)
          .get();

      final transactions = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Transactions.fromMap({...data, 'id': doc.id});
      }).toList();

      await _calculateBalance(debtorId);
      await _calculateUSDBalance(debtorId);
      await _updateDebtorBalance(debtorId);

      emit(TransactionsLoaded(transactions: transactions));
    } catch (e) {
      print('Tranzaksiyalarni olishda xatolik: $e');
      emit(TransactionsError(message: 'Xatolik yuz berdi: $e'));
    }
  }

  // Tranzaksiyani yangilash
  Future<void> updateTransaction({
    required String debtorId,
    required String transactionId,
    double? amount,
    Currency? currency,
    String? description,
    TransactionType? type,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (amount != null) {
        updates['amount'] = amount;
      }
      if (currency != null) {
        updates['currency'] = currency.name;
      }
      if (description != null) {
        updates['description'] = description;
      }
      if (type != null) {
        updates['type'] = type.name;
      }

      await _transactionCollection.doc(transactionId).update(updates);

      // Balansni hisoblab, Debtorni yangilash
      await _calculateBalance(debtorId);
      await _calculateUSDBalance(debtorId);
      await _updateDebtorBalance(debtorId);
    } catch (e) {
      print('Tranzaksiyani yangilashda xatolik: $e');
    }
  }

  // Tranzaksiyani o'chirish
  Future<void> deleteTransaction({required String transactionId, required String debtorId}) async {
    try {
      await _transactionCollection.doc(transactionId).delete();


      await _calculateBalance(debtorId);
      await _calculateUSDBalance(debtorId);
      await _updateDebtorBalance(debtorId);
    } catch (e) {
      print('Tranzaksiyani o\'chirishda xatolik: $e');
    }
  }

  // UZS balansni hisoblash
  Future<double> _calculateBalance(String debtorId) async {
    QuerySnapshot transactionsSnapshot = await _firestore
        .collection('transactions')
        .where('debtor_id', isEqualTo: debtorId)
        .get();

    double balance = 0.0;
    for (var doc in transactionsSnapshot.docs) {
      num amount = doc['amount'] ?? 0.0;
      String type = doc['type'] ?? '';
      String currency = doc['currency'] ?? 'UZS';

      if (currency == 'UZS') {
        if (type == 'DEBT') {
          balance -= amount;
        } else if (type == 'CREDIT') {
          balance += amount;
        }
      }
    }
    print('UZS balans: $balance ga o‘zgartirildi');
    return balance;
  }

// USD balansni hisoblash
  Future<double> _calculateUSDBalance(String debtorId) async {
    QuerySnapshot transactionsSnapshot = await _firestore
        .collection('transactions')
        .where('debtor_id', isEqualTo: debtorId)
        .get();

    double usdBalance = 0.0;
    for (var doc in transactionsSnapshot.docs) {
      num amount = doc['amount'] ?? 0.0;
      String type = doc['type'] ?? '';
      String currency = doc['currency'] ?? 'UZS';

      if (currency == 'USD') {
        if (type == 'DEBT') {
          usdBalance -= amount;
        } else if (type == 'CREDIT') {
          usdBalance += amount;
        }
      }
    }
    print('USD balans: $usdBalance ga o‘zgartirildi');
    return usdBalance;
  }

// Ikkala balansni ham yangilash
  Future<void> _updateDebtorBalance(String debtorId) async {
    try {
      final balance = await _calculateBalance(debtorId);
      final usdBalance = await _calculateUSDBalance(debtorId);

      await _debtorCollection.doc(debtorId).update({
        'balance': balance,
        'usd_balance': usdBalance,
      });

      print('Debtor UZS balansi: $balance, USD balansi: $usdBalance yangilandi');
    } catch (e) {
      print('Debtor balansini yangilashda xatolik: $e');
    }
  }

}