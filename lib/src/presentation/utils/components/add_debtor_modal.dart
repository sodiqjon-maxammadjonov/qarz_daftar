import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/debtor/debtor_bloc.dart';

class AddDebtorModal extends StatefulWidget {
  const AddDebtorModal({super.key});

  @override
  State<AddDebtorModal> createState() => _AddDebtorModalState();
}

class _AddDebtorModalState extends State<AddDebtorModal> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
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
            'Yangi qarzdor qo\'shish',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Qarzdor nomi',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                context.read<DebtorBloc>().add(AddDebtorEvent(_nameController.text.trim()));
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