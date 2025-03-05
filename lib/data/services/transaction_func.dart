import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qarz_daftar/presentation/blocs/debtor/debtor_bloc.dart';
import '../../core/models/debtor.dart';
import '../../core/models/transaction.dart';

class TransactionFunc {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Emitter<DebtorState> emit;

  TransactionFunc({required this.emit});

  // ... (oldingi addDebtor va getDebtors funksiyalari)

  Future<void> getTransactionsForDebtor(String debtorId) async {
    print("🔄 getTransactionsForDebtor metodi chaqirildi. Debtor ID: $debtorId");

    emit(DebtorLoading());

    try {
      // Index talab qilinmaydigan so'rov usuli
      QuerySnapshot snapshot = await _firestore
          .collection('transactions')
          .where('debtorId', isEqualTo: debtorId)
          .get();

      // Ma'lumotlarni kodda tartiblash
      List<Transactions> transactions = snapshot.docs
          .map((doc) => Transactions.fromJson(
          doc.data() as Map<String, dynamic>,
          id: doc.id
      ))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Serverda emas, Flutter kodida tartiblash

      print("📋 Tranzaksiyalar ro'yxati tayyorlandi: ${transactions.length} ta tranzaksiya");

      emit(DebtorTransactionsLoaded(transactions: transactions));
    } catch (e) {
      print("❌ Xatolik yuz berdi: $e");
      emit(DebtorFailure("Tranzaksiyalarni olishda xatolik: $e"));
    }
  }

  Future<void> addTransactionToDebtor(String debtorId, double amount, bool isDebt, {String? description}) async {
    print("✅ addTransactionToDebtor metodi chaqirildi. DebtorID: $debtorId, Summa: $amount, isDebt: $isDebt");

    emit(DebtorLoading());

    try {
      // Yangi transaction uchun reference yaratamiz
      DocumentReference transactionRef = _firestore.collection('transactions').doc();
      DocumentReference debtorRef = _firestore.collection('debtors').doc(debtorId);

      // Debtorni olish
      DocumentSnapshot debtorSnapshot = await debtorRef.get();
      Debtor existingDebtor = Debtor.fromFirestore(debtorSnapshot);

      // Yangi tranzaksiya yaratamiz
      Transactions newTransaction = Transactions(
        id: transactionRef.id,
        debtorId: debtorId,
        amount: isDebt ? amount : -amount,
        date: DateTime.now(),
        description: description ?? "Tranzaksiya qo'shildi",
        isDebt: isDebt,
      );

      // Debtorning balansini yangilaymiz
      existingDebtor.balance += isDebt ? amount : -amount;
      existingDebtor.transactions.add(newTransaction);

      // Firestore'ga yangilanganlarni saqlaymiz
      await transactionRef.set(newTransaction.toJson());
      await debtorRef.update(existingDebtor.toJson());

      print("✅ Tranzaksiya muvaffaqiyatli qo'shildi: ${newTransaction.id}");
      emit(DebtorSuccess());
    } catch (e) {
      print("❌ Tranzaksiya qo'shishda xatolik: $e");
      emit(DebtorFailure("Tranzaksiya qo'shishda xatolik: $e"));
    }
  }

}