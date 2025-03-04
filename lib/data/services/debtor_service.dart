import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qarz_daftar/core/models/debtor.dart';
import 'package:qarz_daftar/core/models/transaction.dart';
import 'package:uuid/uuid.dart';
import '../database/db_helper.dart';

class DebtorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DBHelper _dbHelper = DBHelper();
  final String _debtorsCollection = 'debtors';
  final String _transactionsCollection = 'transactions';
  final uuid = Uuid();

  //Debtorlar ro'yxatini olish (Realtime Stream bilan)
  Stream<List<Debtor>> getDebtorsStream() {
    return _firestore.collection(_debtorsCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Debtor.fromFirestore(doc)).toList();
    }).asBroadcastStream(); //Ko'p obunachilar uchun
  }

  //Debtorlarni lokal DB dan olish
  Future<List<Debtor>> getLocalDebtors() async {
    return _dbHelper.getAllDebtors();
  }
  //transactionlarni lokal DB dan olish
  Future<List<Transactions>> getLocalTransactions() async {
    return _dbHelper.getAllTransactions();
  }

  // Bitta debtorni olish
  Future<Debtor?> getDebtor(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_debtorsCollection).doc(id).get();
      if (doc.exists) {
        return Debtor.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      print("Debtor olishda xatolik: $e");
      return null;
    }
  }
  // Yangi debtor qo'shish
  Future<Debtor?> addDebtor(Debtor debtor) async {
    try {
      final debtorId = uuid.v4();
      final newDebtor = Debtor(
        id: debtorId,
        name: debtor.name,
        balance: debtor.balance,
        isDebt: debtor.isDebt,
      );
      await _firestore.collection(_debtorsCollection).doc(debtorId).set(newDebtor.toJson());
      // Lokal bazaga saqlash
      await _dbHelper.insertDebtor(newDebtor);
      return newDebtor;
    } catch (e) {
      print("Debtor qo'shishda xatolik: $e");
      return null;
    }
  }
  // Debtorni yangilash
  Future<void> updateDebtor(Debtor debtor) async {
    try {
      await _firestore.collection(_debtorsCollection).doc(debtor.id).update(debtor.toJson());
      // Lokal bazani yangilash
      await _dbHelper.insertDebtor(debtor);
    } catch (e) {
      print("Debtorni yangilashda xatolik: $e");
    }
  }
  // Debtorni o'chirish (tegishli tranzaksiyalari bilan)
  Future<void> deleteDebtor(String debtorId) async {
    try {
      // Firebase'dan debtorni o'chirish
      await _firestore.collection(_debtorsCollection).doc(debtorId).delete();

      // Firebase'dan tranzaksiyalarni o'chirish
      QuerySnapshot transactionsSnapshot = await _firestore
          .collection(_transactionsCollection)
          .where('debtorId', isEqualTo: debtorId)
          .get();

      for (QueryDocumentSnapshot doc in transactionsSnapshot.docs) {
        await _firestore.collection(_transactionsCollection).doc(doc.id).delete();
      }

      // Lokal bazadan debtorni o'chirish
      await _dbHelper.deleteDebtor(debtorId);

      // Lokal bazadan tranzaksiyalarni o'chirish
      List<Transactions> localTransactions = await getTransactionsForDebtorLocal(debtorId);
      for (Transactions transaction in localTransactions) {
        await _dbHelper.deleteTransaction(transaction.id!);
      }
    } catch (e) {
      print("Debtor va tranzaksiyalarni o'chirishda xatolik: $e");
    }
  }
  // Debtorning tranzaksiyalarini olish (Firebase)
  Stream<List<Transactions>> getTransactionsForDebtor(String debtorId) {
    return _firestore
        .collection(_transactionsCollection)
        .where('debtorId', isEqualTo: debtorId)
        .orderBy('date', descending: true) // Saralash
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Transactions.fromJson(doc.data(), id: doc.id)).toList();
    });
  }

  // Debtorning tranzaksiyalarini olish (Lokal)
  Future<List<Transactions>> getTransactionsForDebtorLocal(String debtorId) async {
    List<Transactions> allTransactions = await getLocalTransactions();
    return allTransactions.where((transaction) => transaction.debtorId == debtorId).toList();
  }

  // Yangi tranzaksiya qo'shish
  Future<void> addTransaction(Transactions transaction) async {
    try {
      final transactionId = uuid.v4();
      final newTransaction = Transactions(
          id: transactionId,
          debtorId: transaction.debtorId,
          amount: transaction.amount,
          date: transaction.date,
          description: transaction.description,
          isDebt: transaction.isDebt
      );
      // Tranzaksiyani Firebase'ga qo'shish
      await _firestore.collection(_transactionsCollection).doc(transactionId).set(newTransaction.toJson());
      // Tranzaksiyani lokal bazaga saqlash
      await _dbHelper.insertTransaction(newTransaction);

      //Debtorning balansini yangilash
      Debtor? debtor = await getDebtor(transaction.debtorId);
      if (debtor != null) {
        double newBalance = debtor.balance;
        if (transaction.isDebt) {
          newBalance -= transaction.amount;
        } else {
          newBalance += transaction.amount;
        }

        //Balansni yangilash
        debtor.balance = newBalance;
        await updateDebtor(debtor);
      }
    } catch (e) {
      print("Tranzaksiya qo'shishda xatolik: $e");
    }
  }
  // Umumiy balanslarni hisoblash
  Future<Map<String, double>> calculateTotalBalances() async {
    double totalDebt = 0.0;
    double totalReceivable = 0.0;

    List<Debtor> debtors = await getLocalDebtors();

    for (var debtor in debtors) {
      if (debtor.isDebt) {
        totalDebt += debtor.balance;
      } else {
        totalReceivable += debtor.balance;
      }
    }

    return {
      'totalDebt': totalDebt,
      'totalReceivable': totalReceivable,
    };
  }
  // Lokal DB dan Firebasega sinxronlash
  Future<void> syncData() async {
    try {
      // Avval Firebase dan ma'lumotlarni o'qib olamiz
      final firebaseDebtors = await _firestore.collection(_debtorsCollection).get();

      // Lokal bazadagi debtorlar
      final localDebtors = await getLocalDebtors();
      // Agar localda  firebase da yoq bolsa  qoshadi
      for (var debtor in localDebtors) {
        if (!firebaseDebtors.docs.any((doc) => doc.id == debtor.id)) {
          await _firestore.collection(_debtorsCollection).doc(debtor.id).set(debtor.toJson());
        }
      }

      //  Firebase dagi debtorlarni yangilash (agar localda yangilangan bo'lsa)
      for (var doc in firebaseDebtors.docs) {
        final firebaseDebtor = Debtor.fromFirestore(doc);
        final localDebtor = localDebtors.firstWhere((element) => element.id == firebaseDebtor.id, orElse: () => Debtor(id: '', name: '', isDebt: false, balance: 0.0)); //agar topilmasa default qiymat
        if (localDebtor.id.isNotEmpty && localDebtor.toJson() != firebaseDebtor.toJson()) {
          await _firestore.collection(_debtorsCollection).doc(doc.id).update(localDebtor.toJson());
        }
      }
      final firebaseTransactions = await _firestore.collection(_transactionsCollection).get();
      // Lokal bazadagi transactionlar
      final localTransactions = await getLocalTransactions();
      // Agar localda  firebase da yoq bolsa  qoshadi
      for (var transaction in localTransactions) {
        if (!firebaseTransactions.docs.any((doc) => doc.id == transaction.id)) {
          await _firestore.collection(_transactionsCollection).doc(transaction.id).set(transaction.toJson());
        }
      }

      //  Firebase dagi transactionlarni yangilash (agar localda yangilangan bo'lsa)
      for (var doc in firebaseTransactions.docs) {
        final firebaseTransaction = Transactions.fromJson(doc.data(), id: doc.id);
        final localTransaction = localTransactions.firstWhere((element) => element.id == firebaseTransaction.id, orElse: () => Transactions(debtorId: '', amount: 0.0, date: DateTime.now(), isDebt: false)); //agar topilmasa default qiymat
        if (localTransaction.id != null && localTransaction.toJson() != firebaseTransaction.toJson()) {
          await _firestore.collection(_transactionsCollection).doc(doc.id).update(localTransaction.toJson());
        }
      }
      print("Ma'lumotlar muvaffaqiyatli sinxronlandi!");
    } catch (e) {
      print("Sinxronlashda xatolik: $e");
    }
  }
}