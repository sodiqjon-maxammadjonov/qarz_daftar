import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qarz_daftar/core/models/debtor.dart';

class DebtorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection nomi
  final String _collection = 'debtors';

  // Barcha debtorlarni olish
  Future<List<Debtor>> getAllDebtors() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Debtor.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Debtorlarni olishda xatolik: $e');
    }
  }

  // ID bo'yicha debtor olish
  Future<Debtor> getDebtorById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(id)
          .get();

      if (!doc.exists) {
        throw Exception('Debtor topilmadi');
      }

      return Debtor.fromFirestore(doc);
    } catch (e) {
      throw Exception('Debtorni olishda xatolik: $e');
    }
  }

  // Yangi debtor qo'shish
  Future<String> addDebtor(String name, double amount, bool isDebt) async {
    try {
      if (name.isEmpty) {
        throw Exception('Ism bo\'sh bo\'lishi mumkin emas');
      }

      // Yangi debtor uchun ID yaratamiz
      DocumentReference docRef = _firestore.collection(_collection).doc();

      // Debtorni yaratamiz
      Debtor newDebtor = Debtor(
        id: docRef.id,
        name: name,
        balance: amount,
        isDebt: isDebt,
      );

      // Firestore'ga yozamiz
      await docRef.set(newDebtor.toJson());

      return docRef.id;
    } catch (e) {
      throw Exception('Debtor qo\'shishda xatolik: $e');
    }
  }

  // Debtorni yangilash
  Future<void> updateDebtor(Debtor debtor) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(debtor.id)
          .update(debtor.toJson());
    } catch (e) {
      throw Exception('Debtorni yangilashda xatolik: $e');
    }
  }

  // Debtorni o'chirish
  Future<void> deleteDebtor(String id) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Debtorni o\'chirishda xatolik: $e');
    }
  }

  // Debtorning balansini yangilash
  Future<void> updateDebtorBalance(String id, double amount, bool isDebt) async {
    try {
      DocumentReference debtorRef = _firestore.collection(_collection).doc(id);

      // Debtorni olish
      DocumentSnapshot debtorSnapshot = await debtorRef.get();

      if (!debtorSnapshot.exists) {
        throw Exception('Debtor topilmadi');
      }

      Debtor existingDebtor = Debtor.fromFirestore(debtorSnapshot);

      // Debtorning balansini yangilaymiz
      double newBalance = existingDebtor.balance;

      if (isDebt) {
        newBalance += amount;
      } else {
        newBalance -= amount;
      }

      // Update Firestore
      await debtorRef.update({
        'balance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Debtor balansini yangilashda xatolik: $e');
    }
  }
}
