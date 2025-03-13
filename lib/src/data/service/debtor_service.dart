import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qarz_daftar/src/presentation/bloc/debtor/debtor_bloc.dart';
import '../models/debtor.dart';

class DebtorService {
  final CollectionReference _debtorCollection;
  final Emitter<DebtorState> emit;

  DebtorService({required this.emit})
      : _debtorCollection = FirebaseFirestore.instance.collection('debtors');

  /// 🟢 **Yangi qarzdor qo‘shish**
  Future<String?> createDebtor(String name) async {
    try {
      emit(DebtorLoading());
      DocumentReference docRef = await _debtorCollection.add({
        'name': name,
        'balance': 0,
        'usd_balance': 0,
        'created_at': FieldValue.serverTimestamp(),
        'is_selected': false,
      });
      emit(DebtorSuccess('Muvaffaqiyatli qo‘shildi'));
      return docRef.id;
    } catch (e) {
      emit(DebtorError(e.toString()));
      print('❌ Xatolik: Debtor yaratishda xatolik: $e');
      return null;
    }
  }

  /// 🟢 **Tanlangan qarzdorlarni olish**
  Future<void> getSelectedDebtors() async {
    try {
      emit(DebtorLoading());

      QuerySnapshot snapshot =
      await _debtorCollection.where('is_selected', isEqualTo: true).get();

      List<Debtor> selectedDebtors = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Debtor.fromMap({...data, 'id': doc.id});
      }).toList();

      emit(DebtorLoaded(selectedDebtors));
    } catch (e) {
      print("❌ Xatolik: getSelectedDebtors: $e");
      emit(DebtorError("Xatolik: $e"));
    }
  }

  /// 🟢 **Barcha qarzdorlarni olish (optional: filter by name)**
  Future<void> getDebtors({String? name}) async {
    try {
      emit(DebtorLoading());

      Query query = _debtorCollection.orderBy('created_at', descending: true);

      // Ishlatish uchun QuerySnapshot olish
      QuerySnapshot snapshot = await query.get();

      List<Debtor> debtors = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Debtor.fromMap({...data, 'id': doc.id});
      }).toList();

      // Agar ism parametri berilgan bo'lsa, local filtering qilish
      if (name != null && name.isNotEmpty) {
        // Kichik harflar bilan solishtirish uchun
        String searchLower = name.toLowerCase();

        // Filter qilish: debtorning ismi qidirilayotgan ism qismini o'z ichiga olsa
        debtors = debtors.where((debtor) {
          return debtor.name.toLowerCase().contains(searchLower);
        }).toList();

        print('Qidirilayotgan ism: $name');
        print('Topilgan debtorlar soni: ${debtors.length}');
      }

      emit(DebtorLoaded(debtors));
    } catch (e) {
      print("❌ Xatolik: getDebtors: $e");
      emit(DebtorError("Xatolik: $e"));
    }
  }

  /// 🟢 **Qarzdorni va unga tegishli tranzaksiyalarni o‘chirish**
  Future<bool> deleteDebtor(String id) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Qarzdorga tegishli barcha tranzaksiyalarni olish
        QuerySnapshot transactionSnapshot = await FirebaseFirestore.instance
            .collection('transactions')
            .where('debtor_id', isEqualTo: id)
            .get();

        // Tranzaksiyalarni o‘chirish
        for (var doc in transactionSnapshot.docs) {
          transaction.delete(doc.reference);
        }

        // Qarzdorning o‘zini o‘chirish
        transaction.delete(_debtorCollection.doc(id));
      });

      return true;
    } catch (e) {
      print('❌ Xatolik: deleteDebtor: $e');
      return false;
    }
  }

  Future<bool> updateDebtor(
      String id, {
        String? name,
        int? balance,
        int? usdBalance,
        bool? isSelected,
      }) async {
    try {
      Map<String, dynamic> updatedData = {};

      if (name != null) updatedData['name'] = name;
      if (balance != null) updatedData['balance'] = balance;
      if (usdBalance != null) updatedData['usd_balance'] = usdBalance;
      if (isSelected != null) updatedData['is_selected'] = isSelected;

      if (updatedData.isNotEmpty) {
        await _debtorCollection.doc(id).update(updatedData);
      }

      return true;
    } catch (e) {
      print('❌ Xatolik: updateDebtor: $e');
      return false;
    }
  }

}
