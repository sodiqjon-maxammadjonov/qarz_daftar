import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qarz_daftar/src/presentation/utils/components/edit_debtor_modal.dart';
import 'package:qarz_daftar/src/presentation/utils/utilite/number_text.dart';

import '../../../data/models/debtor.dart';
import '../../bloc/debtor/debtor_bloc.dart';

class DebtorCard extends StatelessWidget {
  final Debtor debtor;
  final VoidCallback? onTap;
  const DebtorCard({super.key, required this.debtor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(debtor.name),
              Row(
                children: [
                  NumberText(
                    number: debtor.usdBalance,
                    style: TextStyle(
                      color: debtor.usdBalance < 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text("\$",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Balans: '),
              Row(
                children: [
                  NumberText(
                    number: debtor.balance,
                    style: TextStyle(
                      color: debtor.balance < 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    width: 5,
                  ),
                  Text('sum',style: TextStyle(fontWeight: FontWeight.w700,color: Colors.grey.shade500))
                ],
              ),
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
                child: Text('O‘chirish', style: TextStyle(color: Colors.red)),
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
        content: EditDebtorModal(debtor: debtor),
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
              context.read<DebtorBloc>().add(DeleteDebtorEvent(debtor.id));
              Navigator.pop(context);
            },
            child: const Text('Ha', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
