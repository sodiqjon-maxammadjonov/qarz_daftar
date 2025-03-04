import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qarz_daftar/core/models/debtor.dart';
import 'package:qarz_daftar/presentation/blocs/debtor/debtor_bloc.dart';

import '../../core/models/transaction.dart';

class DebtorFunc {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Emitter<DebtorState> emit;

  DebtorFunc({required this.emit});

  Future<void> addDebtor(String name, double amount, bool isDebt) async {
    print("✅ addDebtor metodi chaqirildi. Kiritilgan ism: $name, Summa: $amount, isDebt: $isDebt");

    if (name.isEmpty) {
      print("⚠️ Xatolik: Ism bo'sh bo'lishi mumkin emas!");
      emit(DebtorFailure("Ism bo'sh bo'lishi mumkin emas!"));
      return;
    }

    emit(DebtorLoading());
    print("⏳ Debtor qo'shish jarayoni boshlandi...");

    try {
      // Yangi debtor uchun ID yaratamiz
      DocumentReference docRef = _firestore.collection('debtors').doc();
      print("📌 Yangi hujjat yaratildi. ID: ${docRef.id}");

      // Yangi transaction uchun ID yaratamiz
      DocumentReference transactionRef = _firestore.collection('transactions').doc();

      // **Transactionni yaratamiz**
      Transactions newTransaction = Transactions(
        id: transactionRef.id,
        debtorId: docRef.id,
        amount: isDebt ? amount : -amount, // Men qarzdorman -> +, Menga qarzdor -> -
        date: DateTime.now(),
        description: "Yangi qarz qo'shildi",
        isDebt: isDebt,
      );

      // **Debtorni yaratamiz**
      Debtor newDebtor = Debtor(
        id: docRef.id,
        name: name,
        balance: isDebt ? amount : -amount, // Balansga ham qo'shish kerak
        isDebt: isDebt,
        transactions: [newTransaction], // Debtorning ichida transactions saqlanadi
      );

      print("📝 Yangi Debtor obyekti yaratildi: ${newDebtor.toJson()}");

      // **Firestore'ga yozamiz**
      await docRef.set(newDebtor.toJson());
      await transactionRef.set(newTransaction.toJson());
      print("✅ Firestore bazasiga muvaffaqiyatli saqlandi!");

      emit(DebtorSuccess());
      print("🎉 Debtor muvaffaqiyatli qo'shildi: ${newDebtor.name}");
    } catch (e) {
      print("❌ Xatolik yuz berdi: $e");
      emit(DebtorFailure("Debtor qo'shishda xatolik: $e"));
    }
  }


  /// **Firestore'dan barcha debtorlarni olish metodi**
  Future<void> getDebtors() async {
    print("🔄 getDebtors metodi chaqirildi...");

    emit(DebtorLoading());

    try {
      QuerySnapshot snapshot = await _firestore.collection('debtors').get();
      print("📦 Firestore'dan ${snapshot.docs.length} ta debtor olindi.");

      // Hujjatlarni Debtor modeliga o'tkazish
      List<Debtor> debtors = snapshot.docs.map((doc) {
        return Debtor.fromFirestore(doc);
      }).toList();

      print("📋 Debtorlar ro'yxati tayyorlandi: ${debtors.length} ta debtor");

      emit(DebtorsLoaded(debtors: debtors));
    } catch (e) {
      print("❌ Xatolik yuz berdi: $e");
      emit(DebtorFailure("Debtorlarni olishda xatolik: $e"));
    }
  }
}