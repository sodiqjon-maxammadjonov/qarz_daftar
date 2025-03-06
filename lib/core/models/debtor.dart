import 'package:cloud_firestore/cloud_firestore.dart';

class Debtor {
  final String id;
  final String name;
  double balance;
  final bool isDebt; // true = men qarzdorman, false = menga qarzdor

  Debtor({
    required this.id,
    required this.name,
    this.balance = 0.0,
    required this.isDebt,
  });

  // Firestore'dan ma'lumot o'qish uchun
  factory Debtor.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return Debtor(
      id: doc.id,
      name: data['name'] ?? '',
      balance: (data['balance'] ?? 0.0).toDouble(),
      isDebt: data['isDebt'] ?? false,
    );
  }

  // Firestore'ga ma'lumot yozish uchun
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'balance': balance,
      'isDebt': isDebt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Yangilangan debtor yaratish
  Debtor copyWith({
    String? id,
    String? name,
    double? balance,
    bool? isDebt,
  }) {
    return Debtor(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      isDebt: isDebt ?? this.isDebt,
    );
  }

  // Balansni manfiy yoki musbat belgi bilan olish
  double get signedBalance => isDebt ? -balance : balance;
}