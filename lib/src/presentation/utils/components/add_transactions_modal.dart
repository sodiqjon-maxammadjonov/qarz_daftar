import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qarz_daftar/src/presentation/utils/utilite/number_text_field.dart';

import '../../../data/models/currency_and_type.dart';
import '../../bloc/transaction/transactions_bloc.dart';

class AddTransactionModal extends StatefulWidget {
  final String debtorId;
  const AddTransactionModal({super.key, required this.debtorId});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Currency _selectedCurrency = Currency.UZS;
  TransactionType _selectedType = TransactionType.DEBT;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: keyboardHeight,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Yangi tranzaksiya qo\'shish',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          NumberTextField(
              controller: _amountController,
            label: 'Miqdor',
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
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Tavsif',
              border: OutlineInputBorder(),
            ),
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
                  AddTransactions(
                    date: DateTime.now(),
                    debtorId: widget.debtorId,
                    amount: double.parse(cleanAmount),
                    currency: _selectedCurrency,
                    description: _descriptionController.text.trim(),
                    type: _selectedType,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Qo\'shish'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
