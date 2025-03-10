import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qarz_daftar/core/models/debtor.dart';
import 'package:qarz_daftar/core/models/transaction.dart';

class DebtorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection nomi
  final String _collection = 'debtors';

  // Barcha debtorlarni olish
  Future<List<Debtor>> getAllDebtors({String? searchQuery}) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .orderBy('updatedAt', descending: true);

      // Agar qidiruv so'rovi bo'lsa, filtrlash qo'shamiz
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Kichik harflarga o'tkazamiz (case-insensitive qidiruv uchun)
        String searchLower = searchQuery.toLowerCase();

        // Firestore'da to'g'ridan-to'g'ri matnli qidiruv cheklangan, shuning uchun
        // avval hamma ma'lumotlarni olib, keyin filtrlash qilamiz
        QuerySnapshot snapshot = await query.get();

        // Ma'lumotlarni filtrlash
        List<DocumentSnapshot> filteredDocs = snapshot.docs.where((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String name = data['name']?.toString().toLowerCase() ?? '';
          return name.contains(searchLower);
        }).toList();

        return filteredDocs
            .map((doc) => Debtor.fromFirestore(doc))
            .toList();
      } else {
        // Oddiy holda hamma ma'lumotlarni qaytaramiz
        QuerySnapshot snapshot = await query.get();
        return snapshot.docs
            .map((doc) => Debtor.fromFirestore(doc))
            .toList();
      }
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
  Future<String> addDebtor(String name, bool isDebt) async {
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
      // Firestore transaction boshlaymiz
      WriteBatch batch = _firestore.batch();

      // Debtorni o'chiramiz
      DocumentReference debtorRef = _firestore.collection(_collection).doc(id);
      batch.delete(debtorRef);

      // Debtor bilan bog'liq tranzaksiyalarni topamiz
      QuerySnapshot transactionsSnapshot = await _firestore
          .collection('transactions')
          .where('debtorId', isEqualTo: id)
          .get();

      // Har bir tranzaksiyani o'chiramiz
      for (var doc in transactionsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Batchni bajarish
      await batch.commit();
    } catch (e) {
      throw Exception('Debtorni va uning tranzaksiyalarini o\'chirishda xatolik: $e');
    }
  }

  // Debtorning balansini barcha tranzaksiyalardan hisoblash
  Future<void> recalculateDebtorBalance(String debtorId) async {
    try {
      // Debtorni olish
      DocumentReference debtorRef = _firestore.collection(_collection).doc(debtorId);
      DocumentSnapshot debtorSnapshot = await debtorRef.get();

      if (!debtorSnapshot.exists) {
        throw Exception('Debtor topilmadi');
      }

      Debtor debtor = Debtor.fromFirestore(debtorSnapshot);

      // Barcha tranzaksiyalarni olish
      QuerySnapshot transactionsSnapshot = await _firestore
          .collection('transactions')
          .where('debtorId', isEqualTo: debtorId)
          .get();

      // Balansni hisoblash
      double totalBalance = 0.0;

      for (var doc in transactionsSnapshot.docs) {
        Transactions transaction = Transactions.fromFirestore(doc);

        // Agar transaction isDebt true bo'lsa, qo'shamiz (qarzdorlik ortgan)
        // Agar false bo'lsa, ayiramiz (qarzdorlik kamaygan)
        if (transaction.isDebt) {
          totalBalance += transaction.amount;
        } else {
          totalBalance -= transaction.amount;
        }
      }

      // Balans manfiy yoki musbat ekanligiga qarab isDebt ni belgilash
      bool isDebt = totalBalance > 0;
      double absBalance = totalBalance.abs();

      // Update Firestore - isDebt va balance ni yangilash
      await debtorRef.update({
        'balance': absBalance,
        'isDebt': isDebt,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Debtor balansini hisoblashda xatolik: $e');
    }
  }
}