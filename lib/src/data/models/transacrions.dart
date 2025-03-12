import 'package:cloud_firestore/cloud_firestore.dart';
import 'currency_and_type.dart';

class Transactions {
  final String id;
  final String debtorId;
  final double amount;
  final Currency currency;
  final String description;
  final DateTime date;
  final TransactionType type;

  Transactions({
    required this.id,
    required this.debtorId,
    required this.amount,
    required this.currency,
    required this.description,
    required this.date,
    required this.type,
  });

  // Copy with method
  Transactions copyWith({
    String? id,
    String? debtorId,
    double? amount,
    Currency? currency,
    String? description,
    DateTime? date,
    TransactionType? type,
  }) {
    return Transactions(
      id: id ?? this.id,
      debtorId: debtorId ?? this.debtorId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'debtor_id': debtorId,
      'amount': amount,
      'currency': currency.name,
      'description': description,
      'date': Timestamp.fromDate(date),
      'type': type.name,
    };
  }

  // Firestore dan o'qish uchun factory constructor
  factory Transactions.fromMap(Map<String, dynamic> map) {
    return Transactions(
      id: map['id'],
      debtorId: map['debtor_id'],
      amount: map['amount'],
      currency: CurrencyExtension.fromString(map['currency']),
      description: map['description'],
      date: (map['date'] as Timestamp).toDate(),
      type: TransactionTypeExtension.fromString(map['type']),
    );
  }

  // Biznes logikasi uchun yordamchi metodlar
  bool get isDebt => type == TransactionType.DEBT;
  bool get isCredit => type == TransactionType.CREDIT;
}
