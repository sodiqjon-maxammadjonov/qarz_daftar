import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qarz_daftar/core/models/transaction.dart';

class TransactionsCard extends StatelessWidget {
  final Transactions transaction;

  const TransactionsCard({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(transaction.description),
        subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm').format(transaction.date)),
        trailing: Text('${transaction.amount}'),
      ),
    );
  }
}