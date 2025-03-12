import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qarz_daftar/src/core/themes/app_theme.dart';
import 'package:qarz_daftar/src/data/models/transacrions.dart';
import 'package:qarz_daftar/src/presentation/bloc/transaction/transactions_bloc.dart';
import 'package:qarz_daftar/src/presentation/utils/components/edit_debtor_modal.dart';
import 'package:qarz_daftar/src/presentation/utils/components/edit_transaction_modal.dart';
import 'package:qarz_daftar/src/presentation/utils/utilite/date_text.dart';
import 'package:qarz_daftar/src/presentation/utils/utilite/number_text.dart';

class TransactionsCard extends StatelessWidget {
  final String debtorId;
  final Transactions transaction;
  final VoidCallback? onTap;
  const TransactionsCard({super.key, required this.transaction, this.onTap, required this.debtorId});

  @override
  Widget build(BuildContext context) {
    Color textColor = transaction.isDebt ? AppTheme.debtColor : AppTheme.creditColor;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(transaction.description),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SanaText(date: transaction.date),
              NumberText(number: transaction.amount.toInt(),style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600
              ),),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(CupertinoIcons.ellipsis_vertical),
            onSelected: (value) {
              if (value == 'edit') {
                _editDebtor(context);
              } else if (value == 'delete') {
                _deleteDebtor(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Tahrirlash'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('O‘chirish',style: TextStyle(color: Colors.red),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editDebtor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tahrirlash'),
        content: EditTransactionModal(debtorId, transaction),
      ),
    );
  }

  void _deleteDebtor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O‘chirish'),
        content: const Text('Haqiqatan ham o‘chirmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yo‘q'),
          ),
          TextButton(
            onPressed: () {
              context.read<TransactionsBloc>().add(DeleteTransactions(transaction.id,debtorId));
              Navigator.pop(context);
            },
            child: const Text('Ha', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
