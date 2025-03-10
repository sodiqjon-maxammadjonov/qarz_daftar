import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qarz_daftar/core/models/transaction.dart';
import 'package:qarz_daftar/data/services/debtor_service.dart';
import 'package:intl/intl.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DebtorService _debtorService = DebtorService();
  final String _collection = 'transactions';

  // Tranzaksiyalarni debtorId bo'yicha olish, oylik guruhlangan holda
  Future<Map<String, List<Transactions>>> getMonthlyTransactionsForDebtor(String debtorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('debtorId', isEqualTo: debtorId)
          .orderBy('date', descending: true)
          .get();

      List<Transactions> transactions = snapshot.docs
          .map((doc) => Transactions.fromFirestore(doc))
          .toList();

      // Tranzaksiyalarni oylik guruhlash
      Map<String, List<Transactions>> monthlyTransactions = {};
      for (var transaction in transactions) {
        String monthYear = DateFormat('yyyy-MM').format(transaction.date);
        if (!monthlyTransactions.containsKey(monthYear)) {
          monthlyTransactions[monthYear] = [];
        }
        monthlyTransactions[monthYear]!.add(transaction);
      }

      return monthlyTransactions;
    } catch (e) {
      throw Exception('Tranzaksiyalarni olishda xatolik: $e');
    }
  }

  Future<String> addTransaction(String debtorId, double amount, bool isDebt, String description) async {
    try {
      DocumentReference transactionRef = _firestore.collection(_collection).doc();

      Transactions newTransaction = Transactions(
        id: transactionRef.id,
        debtorId: debtorId,
        amount: amount,
        date: DateTime.now(),
        description: description,
        isDebt: isDebt,
      );

      await transactionRef.set(newTransaction.toJson());

      // Tranzaksiya qo'shilgandan so'ng balansni qayta hisoblash
      await _debtorService.recalculateDebtorBalance(debtorId);

      return transactionRef.id;
    } catch (e) {
      throw Exception('Tranzaksiya qo\'shishda xatolik: $e');
    }
  }

  Future<void> updateTransaction(Transactions transaction) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(transaction.id)
          .update(transaction.toJson());

      // Tranzaksiya yangilangandan so'ng balansni qayta hisoblash
      await _debtorService.recalculateDebtorBalance(transaction.debtorId);
    } catch (e) {
      throw Exception('Tranzaksiyani yangilashda xatolik: $e');
    }
  }

  Future<void> deleteTransaction(String transactionId, String debtorId) async {
    try {
      await _firestore.collection(_collection).doc(transactionId).delete();

      // Tranzaksiya o'chirilgandan so'ng balansni qayta hisoblash
      await _debtorService.recalculateDebtorBalance(debtorId);
    } catch (e) {
      throw Exception('Tranzaksiyani o\'chirishda xatolik: $e');
    }
  }
}