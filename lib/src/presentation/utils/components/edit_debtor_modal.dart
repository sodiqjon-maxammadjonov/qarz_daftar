import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qarz_daftar/src/data/models/debtor.dart';
import '../../bloc/debtor/debtor_bloc.dart';

class EditDebtorModal extends StatefulWidget {
  final Debtor debtor;
  const EditDebtorModal({super.key, required this.debtor});

  @override
  _EditDebtorModalState createState() => _EditDebtorModalState();
}

class _EditDebtorModalState extends State<EditDebtorModal> {
  late TextEditingController _nameController;
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.debtor.name);
    _isSelected = widget.debtor.isSelected; // Qarzdorning hozirgi qiymati olinmoqda
  }

  @override
  void dispose() {
    _nameController.dispose();
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
          const Text(
            "Qarzdorni tahrirlash",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Ism",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tanlanganmi?"),
              Switch(
                value: _isSelected,
                onChanged: (value) {
                  setState(() {
                    _isSelected = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<DebtorBloc>().add(
                UpdateDebtorEvent(
                  id: widget.debtor.id,
                  name: _nameController.text.trim(),
                  isSelected: _isSelected,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text("Saqlash"),
          ),
        ],
      ),
    );
  }
}
