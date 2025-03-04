import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qarz_daftar/presentation/blocs/debtor/debtor_bloc.dart';
import '../../../config/themes.dart';

class AddDebtModal extends StatefulWidget {
  const AddDebtModal({Key? key}) : super(key: key);

  @override
  State<AddDebtModal> createState() => _AddDebtModalState();
}

class _AddDebtModalState extends State<AddDebtModal> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sumController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    sumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Yangi qarz qo'shish",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Ism",
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Iltimos, ismni kiriting";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: sumController,
              decoration: const InputDecoration(
                hintText: "Summa",
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Iltimos, summani kiriting";
                }
                if (double.tryParse(value) == null) {
                  return "Iltimos, to'g'ri summa kiriting";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _submitForm(context, isDebt: true);
                    },
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text("Men qarzdorman"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.debtColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _submitForm(context, isDebt: false);
                    },
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text("Menga qarzdor"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.creditColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm(BuildContext context, {required bool isDebt}) {
    if (_formKey.currentState!.validate()) {
      final name = nameController.text.trim();
      final amount = double.parse(sumController.text.trim());

      context.read<DebtorBloc>().add(AddDebtorEvent(name, amount, isDebt));
      Navigator.pop(context); // Modalni yopamiz
    }
  }
}