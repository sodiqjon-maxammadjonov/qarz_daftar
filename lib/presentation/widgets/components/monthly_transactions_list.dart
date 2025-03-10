import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qarz_daftar/core/models/transaction.dart';

class MonthlyTransactionList extends StatelessWidget {
  final String monthYear;
  final List<Transactions> transactions;
  final Function(Transactions)? onDelete;
  final Function(Transactions)? onEdit;

  const MonthlyTransactionList({
    Key? key,
    required this.monthYear,
    required this.transactions,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('yyyy-MM');
    final DateTime date = dateFormat.parse(monthYear);
    final String formattedMonth = DateFormat.yMMMM('uz').format(date);

    final NumberFormat currencyFormat = NumberFormat("#,##0", "uz_UZ");

    double monthlyTotal = 0;
    for (var transaction in transactions) {
      monthlyTotal += !transaction.isDebt ? transaction.amount : -transaction.amount; // teskari logika
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedMonth,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${currencyFormat.format(monthlyTotal.abs())} so\'m', // formatlash
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: monthlyTotal > 0 ? Colors.green : monthlyTotal < 0 ? Colors.red : Colors.grey, // teskari ranglar
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final DateTime transactionDate = transaction.date;
              final String formattedDate = DateFormat('d MMM, HH:mm', 'uz').format(transactionDate);

              return Dismissible(
                key: Key(transaction.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return onDelete != null;
                },
                onDismissed: (direction) {
                  if (onDelete != null) {
                    onDelete!(transaction);
                  }
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: !transaction.isDebt ? Colors.green.shade100 : Colors.red.shade100, // teskari rang
                    child: Icon(
                      !transaction.isDebt ? Icons.arrow_downward : Icons.arrow_upward, // teskari rang
                      color: !transaction.isDebt ? Colors.green : Colors.red, // teskari rang
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          transaction.description,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        '${currencyFormat.format(transaction.amount)} so\'m',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: !transaction.isDebt ? Colors.green : Colors.red, // teskari rang
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(formattedDate),
                  trailing: onEdit != null ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => onEdit!(transaction),
                  ) : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}