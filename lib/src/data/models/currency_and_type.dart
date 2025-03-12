enum Currency {
  UZS,
  USD,
}

extension CurrencyExtension on Currency {
  String get name => toString().split('.').last;

  static Currency fromString(String value) {
    return Currency.values.firstWhere(
          (e) => e.name == value,
      orElse: () => Currency.UZS,
    );
  }
}
enum TransactionType {
  DEBT,
  CREDIT,
}

extension TransactionTypeExtension on TransactionType {
  String get name => toString().split('.').last;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => TransactionType.DEBT,
    );
  }
}
