import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qarz_daftar/config/themes.dart';
import 'package:qarz_daftar/core/models/debtor.dart';
import 'package:qarz_daftar/presentation/blocs/debtor/debtor_bloc.dart';

class AddTransactionModal extends StatefulWidget {
  final Debtor debtor;

  const AddTransactionModal({Key? key, required this.debtor}) : super(key: key);

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final TextEditingController sumController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    sumController.dispose();
    descriptionController.dispose();
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
              "${widget.debtor.name} uchun tranzaksiya",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),

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

            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: "Izoh (ixtiyoriy)",
                prefixIcon: Icon(Icons.description),
              ),
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
                    label: const Text("Qarz beraman"),
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
                    label: const Text("Qarz olaman"),
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
      final amount = double.parse(sumController.text.trim());
      final description = descriptionController.text.trim();

      context.read<DebtorBloc>().add(
          AddTransactionToDebtorEvent(
              debtorId: widget.debtor.id,
              amount: amount,
              isDebt: isDebt,
              description: description.isNotEmpty ? description : null
          )
      );
      Navigator.pop(context); // Modalni yopamiz
    }
  }
}

// Bloc uchun yangi event qo'shish kerak
// DebtorBloc klassingizga quyidagi eventni qo'shing:
// AddTransactionToDebtorEvent(String debtorId, double amount, bool isDebt, {String? description})