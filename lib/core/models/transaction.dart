import 'package:cloud_firestore/cloud_firestore.dart';

class Transactions {
  final String? id; // Transaction ID
  final String debtorId; // Qaysi debtorga tegishli ekanligi
  final double amount;
  final DateTime date;
  final String? description;
  final bool isDebt; // true = qarzdorlik, false = haqdorlik

  Transactions({
    this.id,
    required this.debtorId,
    required this.amount,
    required this.date,
    this.description,
    required this.isDebt,
  });

  // Firestore'dan ma'lumot o'qish uchun
  factory Transactions.fromJson(Map<String, dynamic> json, {String? id}) {
    return Transactions(
      id: id ?? json['id'],
      debtorId: json['debtorId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      date: (json['date'] as Timestamp).toDate(),
      description: json['description'],
      isDebt: json['isDebt'] ?? false,
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
    };
  }
}