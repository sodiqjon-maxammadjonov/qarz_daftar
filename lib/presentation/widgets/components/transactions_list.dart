import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qarz_daftar/core/models/transaction.dart';
import 'package:qarz_daftar/core/models/debtor.dart';
import '../../../config/themes.dart';
import 'add_transaction_modal.dart';

class TransactionListPage extends StatelessWidget {
  final Debtor debtor;

  const TransactionListPage({Key? key, required this.debtor}) : super(key: key);

  String formatNumber(double number) {
    final formatter = NumberFormat("#,###", "uz_UZ");
    return formatter.format(number.abs());
  }

  Widget _buildTransactionCard(BuildContext context, Transactions transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? (transaction.isDebt ? "Qarz" : "To'landi"),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  DateFormat('dd.MM.yyyy – kk:mm').format(transaction.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Text(
              '${transaction.isDebt ? "-" : "+"} ${formatNumber(transaction.amount)} UZS',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: transaction.isDebt ? AppTheme.debtColor : AppTheme.creditColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedTransactions = List<Transactions>.from(debtor.transactions)
      ..sort((a, b) => b.date.compareTo(a.date)); // Eng yangi tranzaksiyalar tepada

    return Scaffold(
      appBar: AppBar(
        title: Text('${debtor.name} tranzaksiyalari'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => AddTransactionModal(debtor: debtor),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balans va statistika kartochkasi
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Umumiy balans',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${formatNumber(debtor.balance)} UZS',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: debtor.balance >= 0
                                ? AppTheme.creditColor
                                : AppTheme.debtColor,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      debtor.balance >= 0
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: debtor.balance >= 0
                          ? AppTheme.creditColor
                          : AppTheme.debtColor,
                      size: 40,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tranzaksiyalar sarlavhasi
            Text(
              'Tranzaksiyalar tarixi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            // Tranzaksiyalar ro'yxati
            Expanded(
              child: sortedTransactions.isEmpty
                  ? Center(
                child: Text(
                  "Hali tranzaksiyalar yo'q",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: sortedTransactions.length,
                itemBuilder: (context, index) {
                  return _buildTransactionCard(
                      context,
                      sortedTransactions[index]
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => AddTransactionModal(debtor: debtor),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}