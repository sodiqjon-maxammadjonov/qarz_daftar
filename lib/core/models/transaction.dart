import 'package:cloud_firestore/cloud_firestore.dart';

class Transactions {
  final String id;
  final String debtorId; // Qaysi debtorga tegishli ekanligi
  final double amount;
  final DateTime date;
  final String description;
  final bool isDebt; // true = qarzdorlik, false = haqdorlik

  Transactions({
    required this.id,
    required this.debtorId,
    required this.amount,
    required this.date,
    required this.description,
    required this.isDebt,
  });

  // Firestore'dan ma'lumot o'qish uchun
  factory Transactions.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return Transactions(
      id: doc.id,
      debtorId: data['debtorId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      description: data['description'] ?? '',
      isDebt: data['isDebt'] ?? false,
    );
  }

  // Firestore'ga ma'lumot yozish uchun
  Map<String, dynamic> toJson() {
    return {
      'debtorId': debtorId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'isDebt': isDebt,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}