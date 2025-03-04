import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qarz_daftar/core/models/transaction.dart';

class Debtor {
  final String id;
  final String name;
  double balance;
  final bool isDebt;
  List<Transactions> transactions;

  Debtor({
    required this.id,
    required this.name,
    this.balance = 0.0,
    required this.isDebt,
    this.transactions = const [],
  });

  // ✅ Firestore'dan ma'lumot o'qish uchun
  factory Debtor.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    List<Transactions> transactionList = [];
    if (data['transactions'] is List) {
      transactionList = (data['transactions'] as List)
          .whereType<Map<String, dynamic>>() // ✅ Noto‘g‘ri tiplarni filtrlaydi
          .map((item) => Transactions.fromJson(item))
          .toList();
    }

    return Debtor(
      id: doc.id,
      name: data['name'] ?? '',
      balance: (data['balance'] ?? 0.0).toDouble(), // ✅ `double` formatiga o‘tkazish
      isDebt: data['isDebt'] ?? false,
      transactions: transactionList,
    );
  }

  // ✅ Firestore'ga ma'lumot yozish uchun
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'balance': balance,
      'isDebt': isDebt,
      'transactions': transactions.map((trx) => trx.toJson()).toList(),
    };
  }

  // ✅ Balansni manfiy yoki musbat belgi bilan olish
  double get signedBalance => isDebt ? -balance : balance;
}
