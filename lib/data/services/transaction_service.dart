import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qarz_daftar/core/models/transaction.dart';
import 'package:qarz_daftar/data/services/debtor_service.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DebtorService _debtorService = DebtorService();

  // Collection nomi
  final String _collection = 'transactions';

  // Debtorga oid tranzaksiyalarni olish
  Future<List<Transactions>> getTransactionsForDebtor(String debtorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('debtorId', isEqualTo: debtorId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Transactions.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Tranzaksiyalarni olishda xatolik: $e');
    }
  }

  // Yangi tranzaksiya qo'shish
  Future<String> addTransaction(String debtorId, double amount, bool isDebt, {String description = ''}) async {
    try {
      // Yangi transaction uchun reference yaratamiz
      DocumentReference transactionRef = _firestore.collection(_collection).doc();

      // Tranzaksiyani yaratamiz
      Transactions newTransaction = Transactions(
        id: transactionRef.id,
        debtorId: debtorId,
        amount: amount,
        date: DateTime.now(),
        description: description.isEmpty ? 'Tranzaksiya qo\'shildi' : description,
        isDebt: isDebt,
      );

      // Tranzaksiyani saqlash
      await transactionRef.set(newTransaction.toJson());

      // Debtorning balansini yangilash
      await _debtorService.updateDebtorBalance(debtorId, amount, isDebt);

      return transactionRef.id;
    } catch (e) {
      throw Exception('Tranzaksiya qo\'shishda xatolik: $e');
    }
  }

  // Tranzaksiyani yangilash
  Future<void> updateTransaction(Transactions transaction, double oldAmount, bool oldIsDebt) async {
    try {
      // Tranzaksiyani avvalgi va yangi miqdorlar o'rtasidagi farqni hisoblash
      double balanceChange = 0;

      // Tranzaksiya tipini o'zgartirish (isDebt)
      if (transaction.isDebt != oldIsDebt) {
        // Tip o'zgargan: avvalgi miqdorni qaytaramiz, so'ng yangi miqdorni qo'shamiz
        if (oldIsDebt) {
          balanceChange = -oldAmount - transaction.amount;
        } else {
          balanceChange = oldAmount + transaction.amount;
        }
      } else {
        // Tip o'zgarmagan: faqat miqdor farqini hisoblaymiz
        balanceChange = transaction.isDebt ?
        (transaction.amount - oldAmount) :
        (oldAmount - transaction.amount);
      }

      // Tranzaksiyani yangilash
      await _firestore
          .collection(_collection)
          .doc(transaction.id)
          .update(transaction.toJson());

      // Debtorning balansini yangilash
      if (balanceChange != 0) {
        DocumentReference debtorRef = _firestore.collection('debtors').doc(transaction.debtorId);
        await debtorRef.update({
          'balance': FieldValue.increment(balanceChange),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Tranzaksiyani yangilashda xatolik: $e');
    }
  }

  // Tranzaksiyani o'chirish
  Future<void> deleteTransaction(String id) async {
    try {
      // Tranzaksiyani olish
      DocumentSnapshot transactionDoc = await _firestore
          .collection(_collection)
          .doc(id)
          .get();

      if (!transactionDoc.exists) {
        throw Exception('Tranzaksiya topilmadi');
      }

      Transactions transaction = Transactions.fromFirestore(transactionDoc);

      // Tranzaksiyani o'chirish
      await _firestore
          .collection(_collection)
          .doc(id)
          .delete();

      // Debtor balansini yangilash (tranzaksiya miqdori qaytariladi)
      DocumentReference debtorRef = _firestore.collection('debtors').doc(transaction.debtorId);

      // Debtorning balansini yangilaymiz
      double balanceChange = transaction.isDebt ? -transaction.amount : transaction.amount;

      await debtorRef.update({
        'balance': FieldValue.increment(balanceChange),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Tranzaksiyani o\'chirishda xatolik: $e');
    }
  }

  // ID bo'yicha tranzaksiya olish
  Future<Transactions> getTransactionById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(id)
          .get();

      if (!doc.exists) {
        throw Exception('Tranzaksiya topilmadi');
      }

      return Transactions.fromFirestore(doc);
    } catch (e) {
      throw Exception('Tranzaksiyani olishda xatolik: $e');
    }
  }
}