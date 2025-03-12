import 'package:cloud_firestore/cloud_firestore.dart';

class BalanceService {
  final CollectionReference _debtorCollection;
  final CollectionReference _transactionCollection;

  BalanceService()
      : _debtorCollection = FirebaseFirestore.instance.collection('debtors'),
        _transactionCollection =
        FirebaseFirestore.instance.collection('transactions');

  /// **Barcha qarzdorlarning balanslarini hisoblash (UZS va USD alohida)**
  Future<Map<String, double>> calculateTotalBalances() async {
    return _calculateBalances(false);
  }

  /// **Faqat `is_checked: true` bo‘lgan qarzdorlarning balanslarini hisoblash**
  Future<Map<String, double>> calculateCheckedBalances() async {
    return _calculateBalances(true);
  }

  /// **Umumiy balanslarni hisoblash (barcha yoki faqat `is_checked: true` bo‘lganlar)**
  Future<Map<String, double>> _calculateBalances(bool onlyChecked) async {
    Query query = _debtorCollection;
    if (onlyChecked) {
      query = query.where('is_selected', isEqualTo: true);
    }

    QuerySnapshot debtorsSnapshot = await query.get();

    double totalNegativeBalanceUZS = 0.0;
    double totalPositiveBalanceUZS = 0.0;
    double totalBalanceUZS = 0.0;

    double totalNegativeBalanceUSD = 0.0;
    double totalPositiveBalanceUSD = 0.0;
    double totalBalanceUSD = 0.0;

    for (var doc in debtorsSnapshot.docs) {
      String debtorId = doc.id;

      double balanceUZS = await _calculateBalance(debtorId, 'UZS');
      double balanceUSD = await _calculateBalance(debtorId, 'USD');

      // UZS bo‘yicha hisob
      if (balanceUZS < 0) {
        totalNegativeBalanceUZS += balanceUZS;
      } else {
        totalPositiveBalanceUZS += balanceUZS;
      }

      // USD bo‘yicha hisob
      if (balanceUSD < 0) {
        totalNegativeBalanceUSD += balanceUSD;
      } else {
        totalPositiveBalanceUSD += balanceUSD;
      }
    }

    // Umumiy balanslarni hisoblash
    totalBalanceUZS = totalPositiveBalanceUZS + totalNegativeBalanceUZS;
    totalBalanceUSD = totalPositiveBalanceUSD + totalNegativeBalanceUSD;

    return {
      'totalNegativeBalanceUZS': totalNegativeBalanceUZS,
      'totalPositiveBalanceUZS': totalPositiveBalanceUZS,
      'totalBalanceUZS': totalBalanceUZS,
      'totalNegativeBalanceUSD': totalNegativeBalanceUSD,
      'totalPositiveBalanceUSD': totalPositiveBalanceUSD,
      'totalBalanceUSD': totalBalanceUSD,
    };
  }

  /// **Debtorning balansini hisoblash (currency bo‘yicha UZS yoki USD)**
  Future<double> _calculateBalance(String debtorId, String currency) async {
    QuerySnapshot transactionsSnapshot = await _transactionCollection
        .where('debtor_id', isEqualTo: debtorId)
        .where('currency', isEqualTo: currency)
        .get();

    double balance = 0.0;
    for (var doc in transactionsSnapshot.docs) {
      num amount = doc['amount'] ?? 0.0;
      String type = doc['type'] ?? '';

      if (type == 'DEBT') {
        balance -= amount; // Qarzdor bo‘lsa balans kamayadi
      } else if (type == 'CREDIT') {
        balance += amount; // To‘lov qilsa balans oshadi
      }
    }
    return balance;
  }
}
