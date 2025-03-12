import 'package:cloud_firestore/cloud_firestore.dart';

class Debtor {
  final int balance;
  final int usdBalance;
  final String id;
  final String name;
  final DateTime createdAt;
  final bool isSelected;

  Debtor({
    required this.usdBalance,
    required this.id,
    required this.name,
    required this.createdAt,
    required this.balance,
    this.isSelected = false,
  });

  Debtor copyWith({
    int? usdBalance,
    String? id,
    String? name,
    DateTime? createdAt,
    int? balance,
    bool? isSelected,
  }) {
    return Debtor(
      usdBalance: usdBalance ?? this.usdBalance,
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      balance: balance ?? this.balance,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'balance': balance,
      'usd_balance': usdBalance,
      'id': id,
      'name': name,
      'created_at': Timestamp.fromDate(createdAt),
      'is_selected': isSelected,
    };
  }

  factory Debtor.fromMap(Map<String, dynamic> map) {
    return Debtor(
      usdBalance: (map['usd_balance'] as num?)?.toInt() ?? 0,
      balance: (map['balance'] as num?)?.toInt() ?? 0,
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isSelected: map['is_selected'] ?? false,
    );
  }
}
