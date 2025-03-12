import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qarz_daftar/src/data/models/transacrions.dart';
import 'package:qarz_daftar/src/presentation/bloc/transaction/transactions_bloc.dart';
import 'package:qarz_daftar/src/presentation/utils/utilite/number_text_field.dart';

import '../../../data/models/currency_and_type.dart';

class EditTransactionModal extends StatefulWidget {
  final String debtorId;
  final Transactions transaction;
  const EditTransactionModal(this.debtorId, this.transaction, );

  @override
  State<EditTransactionModal> createState() => _EditTransactionModalState();
}

class _EditTransactionModalState extends State<EditTransactionModal> {
  late TextEditingController _amountController;
  late Currency _selectedCurrency = Currency.UZS;
  late TransactionType _selectedType = TransactionType.DEBT;

  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _selectedCurrency = widget.transaction.currency;
    _selectedType = widget.transaction.type;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NumberTextField(
            controller: _amountController,
              label: "Miqdor",
            ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Currency>(
            value: _selectedCurrency,
            decoration: const InputDecoration(
              labelText: 'Valyuta',
              border: OutlineInputBorder(),
            ),
            items: Currency.values.map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text(currency.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCurrency = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<TransactionType>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Tranzaksiya turi',
              border: OutlineInputBorder(),
            ),
            items: TransactionType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_amountController.text.trim().isNotEmpty) {
                final String cleanAmount = _amountController.text.replaceAll(' ', '');
                context.read<TransactionsBloc>().add(
                  UpdateTransactions(
                    debtorId: widget.debtorId,
                    amount: double.parse(cleanAmount),
                    currency: _selectedCurrency,
                    type: _selectedType,
                    transactionId: widget.transaction.id,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }
}
