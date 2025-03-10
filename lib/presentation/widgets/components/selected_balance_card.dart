import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qarz_daftar/config/themes.dart';
import 'package:qarz_daftar/core/models/debtor.dart';

class SelectableBalanceCard extends StatelessWidget {
  final List<Debtor> allDebtors;
  final List<Debtor> selectedDebtors;

  const SelectableBalanceCard({
    Key? key,
    required this.allDebtors,
    required this.selectedDebtors,
  }) : super(key: key);

  // Raqamni formatlash
  String formatNumber(double number) {
    final formatter = NumberFormat.currency(
        locale: 'uz_UZ', symbol: '', decimalDigits: 0);
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    // Tanlangan debitorlar uchun balanslar
    double selectedTotalBalance = 0;
    double selectedDebtBalance = 0;
    double selectedCreditBalance = 0;

    // Tanlanmagan debitorlar uchun balanslar
    double unselectedTotalBalance = 0;
    double unselectedDebtBalance = 0;
    double unselectedCreditBalance = 0;

    // Tanlangan debitorlar balansi hisoblash
    for (var debtor in selectedDebtors) {
      if (debtor.isDebt) {
        selectedDebtBalance += debtor.signedBalance.abs();
      } else {
        selectedCreditBalance += debtor.signedBalance.abs();
      }
    }
    selectedTotalBalance = selectedCreditBalance - selectedDebtBalance;

    // Boshqa barcha debitorlar uchun balanslar
    Set<String> selectedIds = selectedDebtors.map((d) => d.id).toSet();
    List<Debtor> unselectedDebtors = allDebtors
        .where((d) => !selectedIds.contains(d.id))
        .toList();

    for (var debtor in unselectedDebtors) {
      if (debtor.isDebt) {
        unselectedDebtBalance += debtor.signedBalance.abs();
      } else {
        unselectedCreditBalance += debtor.signedBalance.abs();
      }
    }
    unselectedTotalBalance = unselectedCreditBalance - unselectedDebtBalance;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tanlangan debitorlar bo'limini faqat tanlangan debitorlar mavjud bo'lganda ko'rsatish
            if (selectedDebtors.isNotEmpty) ...[
              const Text(
                'Tanlangan balans',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${formatNumber(selectedTotalBalance)} UZS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: selectedTotalBalance >= 0 ? AppTheme.creditColor : AppTheme.debtColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BalanceItem(
                    title: 'Qarzdorlar',
                    amount: selectedDebtBalance,
                    formatNumber: formatNumber,
                    isDebt: true,
                  ),
                  _BalanceItem(
                    title: 'Haqdorlar',
                    amount: selectedCreditBalance,
                    formatNumber: formatNumber,
                    isDebt: false,
                  ),
                ],
              ),
              const Divider(height: 32),
            ],

            // Barcha debitorlar balansi
            if (unselectedDebtors.isNotEmpty || selectedDebtors.isEmpty) ...[
              Text(
                selectedDebtors.isNotEmpty ? 'Qolgan balans' : 'Umumiy balans',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${formatNumber(unselectedTotalBalance)} UZS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: unselectedTotalBalance >= 0 ? AppTheme.creditColor : AppTheme.debtColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BalanceItem(
                    title: 'Qarzdorlar',
                    amount: unselectedDebtBalance,
                    formatNumber: formatNumber,
                    isDebt: true,
                  ),
                  _BalanceItem(
                    title: 'Haqdorlar',
                    amount: unselectedCreditBalance,
                    formatNumber: formatNumber,
                    isDebt: false,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Balans elementlari uchun yordamchi widget
class _BalanceItem extends StatelessWidget {
  final String title;
  final double amount;
  final Function(double) formatNumber;
  final bool isDebt;

  const _BalanceItem({
    Key? key,
    required this.title,
    required this.amount,
    required this.formatNumber,
    required this.isDebt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${formatNumber(amount)} UZS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDebt ? AppTheme.debtColor : AppTheme.creditColor,
          ),
        ),
      ],
    );
  }
}